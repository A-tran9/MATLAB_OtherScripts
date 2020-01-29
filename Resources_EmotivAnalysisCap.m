% emotiv_analysis.m - Load output data
% Kyle Mathewson, 2012, Beckman Institute, U Illinois
clear all
close all

% cd C:\Dropbox\experiments\Electrophyis\emotiv

[edf_name, edf_path] = uigetfile('*.edf','Pick any .edf file');
csv_name = [edf_name '.csv'];
TestBenchEDF2CSV([edf_path edf_name],[edf_path csv_name]);
data = csvread([edf_path csv_name],1);

% [beh_name, beh_path] = uigetfile('*.mat','Pick the corresponding psychtoolbox output .mat');
% load([beh_path beh_name])

%parameters
srate = 127.94;
n_chan = 14;


%import data and labels
load('data_labels.mat')

n_points = length(data);

%create the time stamp
timer = 0:1/srate:(length(data)-1)*(1/srate);

%take out the relevant data (-1 since the last time point sometimes is zero
EEG_data = data(1:end-1,3:16);
timer(end) = [];
gyro = data(1:end-1,34:35);
marker = data(1:end-1,36);
EEG_labels = labels(3:16);

block_lims = timer(marker == 99);
time_tics_EEG = timer(marker == 66);
stim_onset_EEG = timer(marker > 0 & marker < 10)';
% stim_onset_EEG(end) = [];
%Filter the data
low_pass = .16;  %.16
high_pass = 30;
EEG_data = kyle_filter(double(EEG_data),srate,low_pass,high_pass,1);


figure; plot(timer,EEG_data(:,3));
% hold on;plot(timer,gyro);


% 
% 
% %---------------
% % ERP
% %----------------
% baseline = 50;
% win_length = 200;
% times = -1*baseline*(1/srate):(1/srate):win_length*(1/srate);
% 
% figure;
% 
% 
% %From the psychtoolbox output
% stim_onset = trial_start-block_start;
% stim_onset(1) = stim_onset_EEG(1);
% trial_data = zeros(baseline+win_length+1,n_chan,length(stim_onset));
% for i = 1:length(stim_onset)
%     trial_data(:,:,i) = EEG_data(find(timer>stim_onset(i),1)-baseline:find(timer>stim_onset(i),1)+win_length,:);
% end
% trial_data = trial_data - repmat(mean(trial_data(1:baseline,:,:)),baseline+win_length+1,1);
% subplot(4,1,1); plot(times,mean(mean(trial_data(:,:,trial_type > 1),3),2));
% hold on;        plot(times,mean(mean(trial_data(:,:,trial_type == 1),3),2),'r'); axis tight;
%     
% %From the EEG
% for i = 1:length(stim_onset_EEG)
%     trial_data_EEG(:,:,i) = EEG_data(find(timer>stim_onset_EEG(i),1)-baseline:find(timer>stim_onset_EEG(i),1)+win_length,:);
% end
% trial_data_EEG = trial_data_EEG - repmat(mean(trial_data_EEG(1:baseline,:,:)),baseline+win_length+1,1);
% subplot(4,1,2); plot(times,mean(mean(trial_data_EEG(:,:,trial_type > 1),3),2));
% hold on;        plot(times,mean(mean(trial_data_EEG(:,:,trial_type == 1),3),2),'r'); axis tight;
%     
% %Adjusted
% [bs] = polyfit(stim_onset,stim_onset_EEG,1);
% stim_onset_adj = stim_onset*bs(1)+bs(2);
% trial_data_adj = trial_data;
% for i = 1:length(stim_onset_adj)
%     trial_data_adj(:,:,i) = EEG_data(find(timer>stim_onset_adj(i),1)-baseline:find(timer>stim_onset_adj(i),1)+win_length,:);
% end
% trial_data_adj = trial_data_adj - repmat(mean(trial_data_adj(1:baseline,:,:)),baseline+win_length+1,1);
% subplot(4,1,3); plot(times,mean(mean(trial_data_adj(:,:,trial_type > 1),3),2));
% hold on;        plot(times,mean(mean(trial_data_adj(:,:,trial_type == 1),3),2),'r'); axis tight;
% 
% 
% 
% 
% %% Artifact rejection for voltage > 100uV
% extremes = squeeze(max(max(abs(trial_data_adj))));
% i_rej = find(extremes > 250);
% rej_flag = zeros(length(stim_onset_adj),1);
% rej_flag(i_rej) = 1;
% 
% subplot(4,1,4); plot(times,mean(mean(trial_data_adj(:,:,trial_type > 1 & rej_flag == 0),3),2));
% hold on;        plot(times,mean(mean(trial_data_adj(:,:,trial_type == 1 & rej_flag == 0),3),2),'r'); axis tight;
% 
% 
% 
% 
% 
% %% All channels butterfly
% % Artifacts - Target P3 all chans
% figure; subplot(2,1,1); plot(times,mean(trial_data_adj(:,:,trial_type > 1),3));
% subplot(2,1,2); plot(times,mean(trial_data_adj(:,:,trial_type == 1),3));
% %Artifacts GONE
% figure; subplot(2,1,1); plot(times,mean(trial_data_adj(:,:,trial_type > 0 & rej_flag == 0),3));
% subplot(2,1,2); plot(times,mean(trial_data_adj(:,:,trial_type == 1 & rej_flag == 0),3));
% 
% 
% 
% %% All channels difference
% figure;
% for i_chan = 1:n_chan
% subplot(n_chan/2,2,i_chan); plot(times,mean(trial_data_adj(:,i_chan,trial_type > 1 & rej_flag == 0),3)); axis tight;
% hold on; plot(times,mean(trial_data_adj(:,i_chan,trial_type == 1 & rej_flag == 0),3),'r'); axis tight;
% end
% 
% 
% 
% %% All trials
% 
% [a i] = sort(trial_type);
% CLim = [-50 50];
% figure; subplot(1,2,1); imagesc(times,a,squeeze(mean(trial_data_adj(:,:,:),2))',CLim);
%         subplot(1,2,2); imagesc(times,a,squeeze(mean(trial_data_adj(:,:,rej_flag== 0),2))',CLim);
% figure;
% for i_chan = 1:n_chan
% subplot(n_chan/2,2,i_chan); imagesc(times,a,squeeze(trial_data_adj(:,i_chan,i))',CLim);
% end
% 
% 
% 
% 
% %--FFT
% 
% test = mean(trial_data_adj(:,:,trial_type > 0 & rej_flag == 0),3);
% A = fft(test,256);
% B = A.*conj(A)/256;
% freq = srate*(0:(256/2)-1)/256;
% figure; plot(freq,(B(1:128,:)));
%    
% freq = srate*(0:(256/2)-1)/256;
% B_all = zeros(128,14,round((length(EEG_data)-256)/128));
% win = 0;
% for i_win = 1:10:length(EEG_data)-256
%     win = win+1;
%     A = fft(EEG_data(i_win:i_win+256,:),256);
%     B = A.*conj(A)/256;
%     B_all(:,:,win) = B(1:128,:);
% end
% figure; imagesc(1:4301,freq,squeeze(log10(B_all(:,8,:))));
% xlabel('Time Point')
% ylabel('Frequency (Hz)')
% 
% %All Trials
% trial_data_adj_temp = reshape(trial_data_adj,[251,n_chan,n_trials]);
% A = fft(trial_data_adj_temp,256);
% B = A.*conj(A)/256;
% trial_data_fft = reshape(B,[256,n_chan,n_trials]);
% trial_data_fft = trial_data_fft(1:128,:,:);
% 
