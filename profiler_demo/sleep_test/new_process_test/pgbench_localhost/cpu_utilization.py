#Raymond Schooley ravschoo@uw.edu 8-18-2019

inFile = open("./Data/cpu.tsv", "r")
outFile = open("./cpu_utilization.tsv", "w")

tab = "\t"
nL = "\n"
time = 0
metric = 1
value = 2
utilization = "Utilization"
idle = "Idle"
metrics = ["vCpuTimeUserMode", "vCpuTimeKernelMode", "vCpuTimeIOWait", "vCpuTimeIntSrvc", "vCpuTimeSoftIntSrvc"]

outFile.write("Time" + tab + "Metric" + tab + "Value" + nL)

#Create a 2d array that will hold all the times in first row, utilization in second, and idle in third
data = list()

lineNumber = 0

for line in inFile:
    lineNumber = lineNumber + 1
    if lineNumber == 1:
        continue
    line = line.strip(nL)
    line = line.split(tab)
    #search the array to see if this time exists
    sampleTime = float(line[time])
    index = -1
    for i in range(len(data)):
        if (data[i][0] == sampleTime):
            index = i
            if line[metric] in metrics:
                print "Line number: " + str(lineNumber)
                data[i][1] = data[i][1] + int(line[value])
            else:
                #print str(i) + " ", data
                data[i][2] = int(line[value])

    if (index == -1 and line[metric] in metrics):
        #print "Line number: " + str(lineNumber)
        data.append([float(line[time]), int(line[value]), 0])
    elif (index == -1 and line[metric] == "vCpuIdleTime"):
        #print "Line number: " + str(lineNumber)
        data.append([float(line[time]), 0, int(line[value])])
        

for datum in data:
    percentUtilized = (float(datum[1]) / (datum[1] + datum[2])) * 100
    percentIdle = (float(datum[2]) / (datum[1] + datum[2])) * 100
    outFile.write(str(datum[0]) + tab + utilization + tab + str(percentUtilized) + nL)
    outFile.write(str(datum[0]) + tab + idle + tab + str(percentIdle) + nL)

inFile.close()
outFile.close()
