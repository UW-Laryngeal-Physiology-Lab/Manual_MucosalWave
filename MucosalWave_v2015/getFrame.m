function [ thisFrame ] = getFrame( fname, currframe )
%getFrame Pulls a current fram from a video file.
%   This function was created in order to make the mucosal wave
%   software compatible with newer versions of MATLAB. Previously, this script
%   used the removed function aviread(). This was replaced with VideoReader,
%   and this script minimally modifies the software to use VideoReader as the
%   arguments/returned parameters are different.
% created: 7/13/16 - Andrew Vamos

% use VideoReader to get frame image data
myMat(:, :) = read(VideoReader(fname), currframe(1));

% create grayscale colormap
cmap(:,:) = (0:(1/(size(myMat, 1)-1)):1)';
cmap(:,2) = cmap(:,1);
cmap(:,3) = cmap(:,1);

%get first frame
thisFrame = struct('cdata', myMat(:, :), ...
'colormap', cmap(:, :));

% if more than one, build structure of all frames
if length(currframe) ~= 1
    
    for x = 2:length(currframe)
        myMat(:, :) = read(VideoReader(fname), currframe(x));
        
        %adds new cell to structure on each iteration building 1 by x
        %structure with two fields - cdata and cmap
        thisFrame(x) = struct('cdata', myMat(:,:), ...
            'colormap', cmap(:,:));
    end
end

end

