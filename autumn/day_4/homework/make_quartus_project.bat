set project_path=%1project
rd /s /q %project_path%
mkdir %project_path%
copy %1*.bdf %project_path%
copy %1*.qpf %project_path%
copy %1*.qsf %project_path%
copy %1*.sdc %project_path%
copy %1*.v %project_path%