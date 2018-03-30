%% SNU gentrification project

% 1. Load data
%data has been manually loaded and cleaned

%2. Lets play with gwachun_apt

% get price/m
price_per_meter = gwachunapt(:,4)./gwachunapt(:,5);
plot(price_per_meter)

price_per_meter = goyangapt(:,4)./goyangapt(:,5);
plot(price_per_meter)

price_per_meter = organized_hanamapt(:,4)./organized_hanamapt(:,5);
plot(price_per_meter)

% goyang, suwon
%20151 ~ 20177
%%
figure
for dataNum  = 1:3
    switch dataNum
        case 1
            metadata = seongnamapt;
        case 2
            metadata = gwachunapt;
        case 3
            metadata = hanamapt;
    end
    %we have to sort hanam data and get mean.
    for i = 1:size(metadata,1)
        if metadata(i,3) == 110
            metadata(i,3) = 1;
        elseif metadata(i,3) == 1120
            metadata(i,3) = 2;
        elseif metadata(i,3) == 2131 || metadata(i,3) == 2130 || metadata(i,3) == 2128 || metadata(i,3) == 2129
            metadata(i,3) = 3;
        end
    end
    

    arrayNum = 1;
    month_metadata = [];
    for year = 2015:1:2017
        for month = 1:12
            temp_array = [];
            p = 1;
            for i = size(metadata,1):-1:1
                if metadata(i,1) == year &&  metadata(i,2)==month
                    temp_array(p,:) = metadata(i,:);
                    p = p+1;
                end
            end
            % calculate mean
            if isempty(temp_array) == 0
                month_metadata(arrayNum,1:3) =[year month  sum(temp_array(:,4))/sum(temp_array(:,5))];
                arrayNum = arrayNum+1;
            end
        end
    end%get mean value for each month
    plot(month_metadata(:,3))
    hold on
    data{dataNum,1} = month_metadata;
end

%% now, we are preprocessing car and factory data.
% sort data and delete NaT
apt_data.sn = data{1,1};
apt_data.gc =  data{2,1};
apt_data.hn = data{3,1};

%dateTime data
car_data.sn = sncar; 
car_data.gc = gccar;
car_data.hn = hncar;

%dateTime data
factory_data.sn = snfactory;
factory_data.gc = gcfactory;
factory_data.hn = hnfactory;

hospital_data.sn = snhospital;
hospital_data.gc = gchospital;
hospital_data.hn = hnhospital;

%cig data
cig_data.sn = sncig;
cig_data.hn = hncig;

clearvars -except apt_data car_data hospital_data factory_data cig_data

%deleting nats from datetime data;
car_data.sn(isnat(car_data.sn)) = [];
car_data.gc(isnat(car_data.gc)) = [];
car_data.hn(isnat(car_data.hn)) = [];

factory_data.sn(isnat(factory_data.sn)) = [];
factory_data.gc(isnat(factory_data.gc)) = [];
factory_data.hn(isnat(factory_data.hn)) = [];

hospital_data.sn(isnan(hospital_data.sn)) = [];
hospital_data.gc(isnan(hospital_data.gc)) = [];
hospital_data.hn(isnan(hospital_data.hn)) = [];

cig_data.sn(isnan(cig_data.sn)) = [];
cig_data.hn(isnan(cig_data.hn)) = [];
%sorting datetime Data

car_data.sn = yyyymmdd(sort(car_data.sn)); 
car_data.gc = yyyymmdd(sort(car_data.gc)); 
car_data.hn = yyyymmdd(sort(car_data.hn)); 

factory_data.sn =  yyyymmdd(sort(factory_data.sn)); 
factory_data.gc = yyyymmdd(sort(factory_data.gc)); 
factory_data.hn = yyyymmdd(sort(factory_data.hn)); 

hospital_data.sn = sort(hospital_data.sn);
hospital_data.gc = sort(hospital_data.gc);
hospital_data.hn = sort(hospital_data.hn);

cig_data.sn = sort(cig_data.sn);
cig_data.hn = sort(cig_data.hn);

%% Now we are going to clean car,factory, and hospital data to interested timeline
%which is 20150101 ~ 20170731
car_data.sn(20170731< car_data.sn | car_data.sn < 20150101) = [];
car_data.gc(20170731< car_data.gc | car_data.gc < 20150101) = [];
car_data.hn(20170731< car_data.hn | car_data.hn < 20150101) = [];

factory_data.sn(20170731< factory_data.sn | factory_data.sn < 20150101) = [];
factory_data.gc(20170731< factory_data.gc | factory_data.gc < 20150101) = [];
factory_data.hn(20170731< factory_data.hn | factory_data.hn < 20150101) = [];


hospital_data.sn(20170731< hospital_data.sn | hospital_data.sn < 20150101) = [];
hospital_data.gc(20170731< hospital_data.gc | hospital_data.gc < 20150101) = [];
hospital_data.hn(20170731< hospital_data.hn | hospital_data.hn < 20150101) = [];

cig_data.sn(20170731< cig_data.sn | cig_data.sn < 20150101) = [];
cig_data.hn(20170731< cig_data.hn | cig_data.hn < 20150101) = [];
%% finally, we are going to merge data by month 
%clearning and initializing year array
clearvars -except apt_data car_data hospital_data factory_data cig_data dpop_data
yearArray_2015 = 20150100:100:20151200;
yearArray_2016 = 20160100:100:20161200;
yearArray_2017 = 20170100:100:20170800;
yearArray = [yearArray_2015 yearArray_2016 yearArray_2017];
%car 
for numPar = 1:4
    switch numPar
        case 1
            metadata = car_data;
        case 2
            metadata = cig_data;
        case 3
            metadata = factory_data;
        case 4
            metadata = hospital_data;
    end
    %sn
    tempArray = [];
    for i = 1:length(yearArray)-1;
        monthCount = 1;
        for z = 1:size(metadata.sn,1)
            if metadata.sn(z,1) > yearArray(i) &&  metadata.sn(z,1) <yearArray(i+1)
                monthCount = monthCount +1 ;
            end
        end
        tempArray(i,1) = monthCount;
    end
    metadata.sn_cumsum = cumsum(tempArray);
    
    %hn
    tempArray = [];
    for i = 1:length(yearArray)-1;
        monthCount = 1;
        for z = 1:size(metadata.hn,1)
            if metadata.hn(z,1) > yearArray(i) &&  metadata.hn(z,1) <yearArray(i+1)
                monthCount = monthCount +1 ;
            end
        end
        tempArray(i,1) = monthCount;
    end
    metadata.hn_cumsum = cumsum(tempArray);
    
    switch numPar
        case 1
            car_data = metadata;
        case 2
            cig_data= metadata;
        case 3
            factory_data= metadata;
        case 4
            hospital_data= metadata;
    end
end

%% now, we are going to prepare for the final data.
% data organization: 
% apt car cig factory hospital dpop
snData =[apt_data.sn(:,3) car_data.sn_cumsum cig_data.sn_cumsum factory_data.sn_cumsum hospital_data.sn_cumsum dpop_data(1,:)'];
hnData = [apt_data.hn(:,3) car_data.hn_cumsum cig_data.hn_cumsum factory_data.hn_cumsum hospital_data.hn_cumsum dpop_data(2,:)'];

reg = MultiPolyRegress(snData(:,2:end-1),snData(:,1),1,'figure')
set(gcf,'Color',[1 1 1])
title('Goodness of Fit - Seongnam')
set(gca,'linewidth',1.6,'FontSize',15,'FontName','Arial')
xlabel('Market Price - hat')
ylabel('Market Price')

reg = MultiPolyRegress(hnData(:,2:end),hnData(:,1),1,'figure')
set(gcf,'Color',[1 1 1])
title('Goodness of Fit - Hanam')
set(gca,'linewidth',1.6,'FontSize',15,'FontName','Arial')
xlabel('Market Price - hat')
ylabel('Market Price')
%% plotting market price
% yearArray_str = mat2cell(yearArray(1:end-1),[1 1])
plot(1:31,hnData(:,1),'LineWidth',2)
set(gca,'XTickLabel',[])
set(gca,'TickDir','out'); % The only other option is 'in'
set(gca,'linewidth',1.6,'FontSize',15,'FontName','Arial')
set(gca, 'box', 'off')
set(gcf,'Color',[1 1 1])
ylabel('10,000 Won/m^2')
xlabel('Time')
xlim([1 31])
hold on
plot(1:31,snData(:,1),'LineWidth',2)
set(gca,'XTickLabel',[])
set(gca,'TickDir','out'); % The only other option is 'in'
set(gca,'linewidth',1.6,'FontSize',15,'FontName','Arial')
set(gca, 'box', 'off')
set(gcf,'Color',[1 1 1])
ylabel('10,000 Won/m^2')
xlabel('Time')
xlim([1 31])
title('Apartment Price')


%% rest of plot_hanam

plot(1:31,hnData(:,2:5),'LineWidth',2)
set(gca,'XTickLabel',[])
set(gca,'TickDir','out'); % The only other option is 'in'
set(gca,'linewidth',1.6,'FontSize',15,'FontName','Arial')
set(gca, 'box', 'off')
set(gcf,'Color',[1 1 1])
ylabel('Number of stores from 2015')
xlabel('Time')
xlim([1 31])

legend('Car Center','Cig Vendor','Factory','Hospital')
legend('Location','northeastoutside')
legend('boxoff')
title('Hanam')

%% rest of plot_sn
plot(1:31,snData(:,2:5),'LineWidth',2)
set(gca,'XTickLabel',[])
set(gca,'TickDir','out'); % The only other option is 'in'
set(gca,'linewidth',1.6,'FontSize',15,'FontName','Arial')
set(gca, 'box', 'off')
set(gcf,'Color',[1 1 1])
ylabel('Number of stores from 2015')
xlabel('Time')
xlim([1 31])

legend('Car Center','Cig Vendor','Factory','Hospital')
legend('Location','northeastoutside')
legend('boxoff')
title('Seongnam')

%% delta population plot
plot(1:31,hnData(:,6),'LineWidth',2)
hold on
plot(1:31,snData(:,6),'LineWidth',2)

set(gca,'XTickLabel',[])
set(gca,'TickDir','out'); % The only other option is 'in'
set(gca,'linewidth',1.6,'FontSize',15,'FontName','Arial')
set(gca, 'box', 'off')
set(gcf,'Color',[1 1 1])
ylabel('\Delta people')
xlabel('Time')
xlim([1 31])

legend('Hanam','SeongNam')
legend('Location','northeastoutside')
legend('boxoff')

title('\Delta polulation')