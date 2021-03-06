modelFileName = 'c_slow_test_cases';
newName = 'c_slow_test_cases_working';
share_factor = 4;

load_system(modelFileName);
save_system(modelFileName, [newName, '.slx']);
close_system(modelFileName);
load_system(newName);

disp('C-Slow Test: Basic_Sub')
c_slow([newName, '/Basic_Sub'], share_factor, true);

disp(' ')
disp('C-Slow Test: Basic_Enb')
c_slow([newName, '/Basic_Enb'], share_factor, true);

disp(' ')
disp('C-Slow Test: Nested_Sub')
c_slow([newName, '/Nested_Sub'], share_factor, true);

disp(' ')
disp('C-Slow Test: Nested_Enb')
c_slow([newName, '/Nested_Enb'], share_factor, true);

disp(' ')
disp('C-Slow Test: Lib_Sub')
c_slow([newName, '/Lib_Sub'], share_factor, true);

disp(' ')
disp('C-Slow Test: Lib_Enb')
c_slow([newName, '/Lib_Enb'], share_factor, true);

save_system(newName);
open_system(newName);