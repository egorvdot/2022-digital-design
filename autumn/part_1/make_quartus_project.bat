set project_path=%1project
rd /s /q %project_path%
mkdir %project_path%
copy %project_path%*.bdf %project_path%
copy %project_path%*.qpf %project_path%
copy %project_path%*.qsf %project_path%
copy %project_path%*.v %project_path%