function headsurf = initHeadsurf(handles)

headsurf = struct(...
    'pathname',filesepStandard(pwd), ...
    'name', 'headsurf', ...
    'handles', struct(...
        'surf',[], ...
        'radiobuttonShowHead',[], ...
        'editTransparency',[], ...
        'menuItemProbeCreate',[], ...
        'menuItemProbeImport',[], ...
        'axes',[] ... 
    ), ...
    'mesh',initMesh(), ...
    'mesh_reduced',initMesh(), ...
    'T_2vol',eye(4), ...
    'center',[], ...
    'centerRotation',[], ...
    'visible',1, ...
    'color',[.69 .74 .67], ...
    'currentPt',[], ...
    'orientation', '', ...
    'checkCompatability',[], ...
    'isempty',@isempty_loc, ...
    'prepObjForSave',[] ...
);

if exist('handles','var')
    headsurf.handles.radiobuttonShowHead = handles.radiobuttonShowHead;
    set(headsurf.handles.radiobuttonShowHead,'enable','off');

    headsurf.handles.editTransparency = handles.editHeadTransparency;
    set(headsurf.handles.editTransparency,'enable','off');

    headsurf.handles.menuItemProbeCreate = handles.menuItemProbeCreate;
    set(headsurf.handles.menuItemProbeCreate,'enable','off');

    headsurf.handles.menuItemProbeImport = handles.menuItemProbeImport;
    set(headsurf.handles.menuItemProbeImport,'enable','off');

    headsurf.handles.axes = handles.axesSurfDisplay;
end


% --------------------------------------------------------------
function b = isempty_loc(headsurf)

b = false;
if isempty(headsurf)
    b = true;
elseif isempty(headsurf.mesh.vertices) | isempty(headsurf.mesh.faces)
    b = true;
end

