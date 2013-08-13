function miniVasExample()
% Example code for how to interact with the miniVAS through MATLAB
% 
% You should also have access to the javadoc that accompanies the
% minivas helper Java class that mediates this interaction. More
% information about all of the available function can be found by
% opening index.html in this documentation.
%
% Interaction with the miniVAS is mediated by a program pVAS that
% must be run on a computer connected to the miniVAS. This code
% talks with pVAS over an internet connection, so the pVAS computer
% must be on the same local network as the computer running MATLAB.
%


% minivas.class must be in the java path
javaaddpath('.');

% connection to the miniVAS must established before doing anything else
% the default constructor connects to the computer described by
%   minivas.pref (which contains ip address and port number).
v = minivas();

% if you'd like to specify a different computer/port then an alternate
%   constructor is available.
% v = minivas('pvas.stanford.edu', 12345);

% one thing that has been suggested is to disable those channels that you
%   will not be using. i am not sure what the purpose of this is, but
%   perhaps it reduces leakage. enabling/disabling channels requires
%   sending 1's and 0's. here i enable the first 15 channels and disables
%   channels 16-30.
v.setChannelsEnabled([ones(1,15) zeros(1,15)]);

% flow may be controlled in several ways. the simplest is just to turn on
%   one channel. there are 30 channels on our miniVAS, so the channel
%   number must be between 1 and 30. here i turn on channel 1 to a flow
%   rate of 300. flow rates must be between 0 and 400.
v.setChannel(1, 300); 

% you can also specify the flow rates for all 30 channels at once. this
%   turns all alternate channels to 0 and 400.
v.setChannels(one(1,30)*400 .* repmat([0 1], 1, 15));

% finally, you can save flow rate configurations on the pVAS computer and
%   load them remotely.
v.loadFile('1.mvf');

% a shortcut for turning all channels off...
v.allChannelsOff();

% when you are finished, you need to disconnect from pVAS.
v.disconnect();

% if you want not only to disconnect, but also to tell pVAS to exit, then
%   use the kill command instead.
v.kill()