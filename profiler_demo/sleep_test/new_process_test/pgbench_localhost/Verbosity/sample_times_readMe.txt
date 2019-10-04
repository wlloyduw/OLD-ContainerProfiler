1) Make sure that you are using ru_profiler.sh from the Verbosity directory that contains the code to record the amount of time it take to capture each sample and then it should write each sample time out to a file.

2) Make sure you are using the rudataall.sh from Verbosity directory that includes the handling of flags.  Flags -v, -c and -p can be used to include vm, container and process-level metrics respectively.  Calling rudataall.sh with no flags mean collect everything.

3) Right now the process is a little manual.  On line 40 of ru_profiler.sh we are making the call to rudataall.sh in a loop.  Each time you want to run the workload with a different verbosity setting or combination of flags you have to manually edit this line.  Also on line 55 I have the sample_times.txt file that is recording each sample time.  I have been just running the work and then moving and renaming this file to reflect the verbosity setting each time. 

4) Other than that you should be able to run any workload the same way as before. 
