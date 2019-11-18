function simdatacopy(source_dir, destination_dir)
cd(source_dir);
fileStructR = dir('**\*R.tif');
fileStructG = dir('**\*G.tif');
parfor n = 1:numel(fileStructR)
    source = fullfile(fileStructR(n).folder, fileStructR(n).name);
    copyfile(source, destination_dir);
end
parfor n = 1:numel(fileStructG)
    source = fullfile(fileStructG(n).folder, fileStructG(n).name);
    copyfile(source, destination_dir);
end
cd(destination_dir);
