import os
import subprocess
import re
import datetime as dt

pathname = "/home/anirudh/Documents/ContainerProfile/quant_12Dec/"
dirs = os.listdir(pathname)
dirs.sort()
#print dirs
j = 0
for i in xrange(len(dirs) - 1):
    #print i
    file1 = pathname+dirs[i]
    file2 = pathname+dirs[i+1]
    missing_filename = "missing_file"+str(i)
    #print dirs[i+1]
    #print (dirs[i].split("_"))
    year2 = int(dirs[i+1].split("_")[0])
    #print year2
    month2 = int(dirs[i+1].split("_")[1])
    date2 = int(dirs[i+1].split("_")[2])
    hour2 = int(dirs[i+1].split("_")[4])
    min2 = int(dirs[i+1].split("_")[5])
    sec2 = int(dirs[i+1].split("_")[6].split(".")[0])

    year1 = int(dirs[i].split("_")[0])
    month1 = int(dirs[i].split("_")[1])
    date1 = int(dirs[i].split("_")[2])
    hour1 = int(dirs[i].split("_")[4])
    min1 = int(dirs[i].split("_")[5])
    sec1 = int(dirs[i].split("_")[6].split(".")[0])

    a = dt.datetime(year2,month2,date2,hour2,min2,sec2)
    b = dt.datetime(year1,month1,date1,hour1,min1,sec1)

    j = j + int((a-b).total_seconds())
    '''
    print year2
    fileNum2 = re.sub('[^0-9]','', dirs[i+1])
    fileNum1 = re.sub('[^0-9]','', dirs[i])
    #print fileNum2
    #print fileNum1
    if fileNum1.endswith("59"):
        j = j + int(fileNum2) - int(fileNum1) - 40
    else:
        j = j + int(fileNum2) - int(fileNum1)
        '''
    delta = str(j)+".json"
    #print delta
    #arg3 = "2>"+missing_filename
    #print arg3
    #print file1
    #subprocess.check_call('./deltav2.sh', file1, file2)
    #bashCommand = "/home/anirudh/Documents/ContainerProfile/profile_kallisto/deltav2.sh file1 file2 2>missing_filename 1>delta"
    #print bashCommand.split()
    #process = subprocess.Popen([bashCommand.split(), stdout=subprocess.PIPE)
    #process = subprocess.Popen(['/home/anirudh/Documents/ContainerProfile/profile_kallisto/deltav2.sh', file1, file2], stdout=)
    #output, error = process.communicate()

    f = open(delta, "w")
    #err = open(missing_filename, "w")
    subprocess.call(["/home/anirudh/Documents/ContainerProfile/profile_kallisto/deltav2.sh", file2, file1], stdout=f)
    #print file1
    #print file2
#print dirs
