function createInstallFile(options)
global installfilename
global platform
global logger 

platform = [];

installfilename = sprintf('%s_install', lower(getAppname()));
[~, exename] = getAppname();

setNamespace(exename)

% Start with a clean slate
cleanup('','','start');

logger = Logger('Install');

atlasDir = getAtlasDir();

if ~exist('options','var') || isempty(options)
    options = 'all';
end

% Find installation path and add it to matlab search paths
dirnameApp = getAppDir();
if isempty(dirnameApp)
    MessageBox('Cannot create installation package. Could not find root application folder.');
    deleteNamespace(exename)
    return;
end
dirnameInstall = filesepStandard(fileparts(which('createInstallFile.m')));
if isempty(dirnameInstall)
    MessageBox('Cannot create installation package. Could not find root installation folder.');
    deleteNamespace(exename)
    return;
end
addpath(dirnameInstall, '-end')
cd(dirnameInstall);

% Set the executable names based on the platform type
platform = setplatformparams();

if ispathvalid([dirnameInstall, installfilename],'dir')
    rmdir_safe([dirnameInstall, installfilename]);
end
if ispathvalid([dirnameInstall, installfilename, '.zip'],'file')
    delete([dirnameInstall, installfilename, '.zip']);
end
mkdir([dirnameInstall, installfilename]);

% Generate executables
if ~strcmp(options, 'nobuild')
    Buildme_Setup();
    Buildme();
    if ~ispc()
        c = str2cell(version(),'.');
        mcrver = sprintf('v%s%s', c{1}, c{2});
        if islinux()
            perl('./makesetup.pl','./run_setup.sh','./setup.sh', mcrver);
        elseif ismac()
            perl('./makesetup.pl','./run_setup.sh','./setup.command', mcrver);
        end
    end
end


myCopyFile([dirnameApp,  'ForwardModel/', platform.mc_exe_name], [dirnameInstall, installfilename, '/', platform.mc_exe_name])

for ii = 1:length(platform.exename)
    myCopyFile([dirnameInstall, platform.exename{ii}], [dirnameInstall, installfilename, '/', platform.exename{ii}]);
end
myCopyFile([dirnameInstall, platform.setup_script], [dirnameInstall, installfilename]);
for ii = 1:length(platform.setup_exe)
    if ispc()
        myCopyFile([dirnameInstall, platform.setup_exe{1}], [dirnameInstall, installfilename, '/installtemp']);
    else
        myCopyFile([dirnameInstall, platform.setup_exe{ii}], [dirnameInstall, installfilename, '/', platform.setup_exe{ii}]);
    end
end
myCopyFile([dirnameApp, 'Group/FuncRegistry'], [dirnameInstall, installfilename, '/Group/FuncRegistry']);
myCopyFile([dirnameApp, 'Refpts/10-5-System_Mastoids_EGI129.csd'], [dirnameInstall, installfilename, '/Refpts']);
myCopyFile([dirnameApp, 'Test'], [dirnameInstall, installfilename, '/Test']);
for ii = 1:length(platform.createshort_script)
    myCopyFile([dirnameInstall, platform.createshort_script{ii}], [dirnameInstall, installfilename]);
end

cfg = ConfigFileClass();
for ii = 1:length(cfg.filenames)
    [pathRelative, filename, ext] = fileparts(getRelativePath(cfg.filenames{ii}, dirnameApp));
    myCopyFile(cfg.filenames{ii}, [dirnameInstall, installfilename, '/', filesepStandard(pathRelative, 'nameonly:dir'), filename, ext]);
end

[pathRelative, filename, ext] = fileparts(getRelativePath(atlasDir(), dirnameApp));

myCopyFile(atlasDir(), [dirnameInstall, installfilename, '/', filesepStandard(pathRelative, 'nameonly:dir'), filename, ext]);
myCopyFile([dirnameInstall, 'makefinalapp.pl'], [dirnameInstall, installfilename]);
myCopyFile([dirnameInstall, 'generateDesktopPath.bat'], [dirnameInstall, installfilename]);
myCopyFile([dirnameInstall, 'README.txt'], [dirnameInstall, installfilename]);
myCopyFile([dirnameInstall, 'uninstall.bat'], [dirnameInstall, installfilename]);
myCopyFile([dirnameApp, 'LastCheckForUpdates.dat'], [dirnameInstall, installfilename]);
for ii = 1:length(platform.iso2meshmex)
    myCopyFile([platform.iso2meshbin, platform.iso2meshmex{ii}], [dirnameInstall, installfilename]);
end

% Zip it all up into a single installation file
zip([dirnameInstall, installfilename, '.zip'], [dirnameInstall, installfilename]);

% Clean up 
cleanup(dirnameInstall, dirnameApp);
deleteNamespace(exename)


