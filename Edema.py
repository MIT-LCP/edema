######Author: SusanCav
import numpy
import random
import pylab
#import statistics

def readResults(filename):
    """
    Reads the textfile named 'filename',
    Categorizes each patient into one of four categories:
    (1) Peripheral but not pulmonary edema
    (2) Peripheral and pulmonary edema
    (3) Both peripheral and pulmonary edema
    (4) Neither peripheral nor pulmonary edema
    etc.
    or puts into Nulls (one of the terms wasn't recovered)--MissingInfo
    
    Returns a set of counts
    """
    dataFile = open(filename, "r")
    lines=[]
    for line in dataFile.readlines():
        lines.append(line.strip())
    Counts = {"PeriOnly": 0, "Both":0, "Neither":0, "PulmOnly":0}
    IDnums = {"CPeriOnly":[], "CBoth": [], "CNeither":[],"CPulmOnly":[], "MIPeriOnly":[], "MIPulmOnly":[], "MINoKnownPeri":[], "MINoKnownPulm":[], "MINeither":[]}
    MissingInfo = {"PeriOnly":0, "PulmOnly":0, "NoKnownPeri":0, "NoKnownPulm":0, "Neither":0}
    MissingHistory = 0
    for line in lines:
        cur = line.split(",")
        if cur[3] == '-1':
            MissingHistory += 1           
        elif cur[1] == '1':
            if cur[2] == '0':
                Counts["PulmOnly"] += 1
                IDnums["CPulmOnly"].append(cur[0])
            elif cur[2] == '1':
                Counts["Both"] += 1
                IDnums["CBoth"].append(cur[0])
            #if cur[2] == -1:
            else:
                MissingInfo["PulmOnly"] += 1
                IDnums["MIPulmOnly"].append(cur[0])
        elif cur[1] == '0':
            if cur[2] == '0':
                Counts["Neither"] +=1
                IDnums["CNeither"].append(cur[0])
            elif cur[2] == '1':
                Counts["PeriOnly"] += 1
                IDnums["CPeriOnly"].append(cur[0])
            #if cur[2] == -1:
            else:
                MissingInfo["NoKnownPulm"] += 1
                IDnums["MINoKnownPulm"].append(cur[0])
        elif cur[1] == '-1':
            if cur[2] == '-1':
                MissingInfo["Neither"] += 1
                IDnums["MINeither"].append(cur[0])
            elif cur[2] == '0':
                MissingInfo["NoKnownPeri"] += 1
                IDnums["MINoKnownPeri"].append(cur[0])
            #if cur[2] == 1:
            else:
                MissingInfo["PeriOnly"] += 1
                IDnums["MIPeriOnly"].append(cur[0])
##        if cur[3] == '-1':
##            MissingHistory += 1

 #   print len(IDnums["CPeriOnly"])
    print Counts, MissingInfo, MissingHistory
    return Counts, MissingInfo, MissingHistory

#readResults("dsfullsetoutput.csv")

##Results:
##Counts({'Both': 838, 'Neither': 12705, 'PeriOnly': 2011, 'PulmOnly': 1904})
##MissingInfo({'PulmOnly': 137, 'PeriOnly': 52, 'NoKnownPulm': 1512,
##'Neither': 724, 'NoKnownPeri': 762})
## No History: 5377

#readResults("rerun2_73.csv")
#readResults("7.3rerun(1).csv")

def readAddendums(filename):
    """
    Reads the textfile named 'filename',
    Categorizes each patient into one of four categories:
    (1) Peripheral but not pulmonary edema
    (2) Peripheral and pulmonary edema
    (3) Both peripheral and pulmonary edema
    (4) Neither peripheral nor pulmonary edema
    etc.
    or puts into Nulls (one of the terms wasn't recovered)--MissingInfo
    
    Returns a set of counts
    """
    dataFile = open(filename, "r")
    lines=[]
    for line in dataFile.readlines():
        lines.append(line.strip())
    addendums = 0
    for line in lines:
        cur = line.split(",")
        if cur[1] == " 1":
            addendums += 1
    print addendums
readAddendums("addendum_data.txt")
        
def buildDict(filename):
    """
    Using file filename, writes a dictionary matching correct values
    to ID number keys of the previously run patients
    """
    dataFile = open(filename, "r")
    lines=[]
    for line in dataFile.readlines():
        lines.append(line.strip())
    correctDict = {}
    for line in lines:
        cur = line.split(",")
        correctDict[cur[0]] = cur[1]+cur[2]+cur[3]
    return correctDict

#print buildDict("Corrected_Data.csv").keys()

def compareIDs(dict1, dict2):
    """
    Just to make sure that all the keys in the test set are
    also in the corrected data set
    """
    
    for key in dict1.keys():
        if key not in dict2.keys():
            print key #should print nothing

def testRun(numTrials, numCases, correctFile, testFile):
    """
    Runs however many numtrials number of trials, each with numcases
    number of patients using DS parse results, to see how the average
    percent correct varies.

    Plots the values on a chart.
    """
    correctDict = buildDict(correctFile)
    testDict = buildDict(testFile)
    accuracy = []
    for trial in range(numTrials):
        wrongPts = []
        numCorrect = 0
        
        for i in range(numCases):
            value = random.choice(testDict.keys())
            if testDict[value] == correctDict[value]:
                numCorrect += 1
            else:
                wrongPts.append(value)
        accuracy.append(float(numCorrect)/numCases)

    sortedaccuracy = sorted(accuracy)
    print numCases
    print "median",numpy.median(sortedaccuracy)
    print "25",numpy.percentile(sortedaccuracy,25)
    print "75",numpy.percentile(sortedaccuracy,75)
    print "mean",numpy.average(sortedaccuracy)
    print "stdev",numpy.std(sortedaccuracy)
 
    pylab.hist(accuracy, bins = 10)
    pylab.suptitle('Bootstrapping with 400 Patient Samples, 10,000 Trials')
    pylab.xlabel('Accuracy')
    pylab.ylabel('Number of Trials') 
    xmin, xmax = pylab.xlim()

    pylab.show()
#testRun(10000, 400, "Corrected_Data.csv", "big_tested_set.csv")
#testRun(10000, 600, "big_tested_set.csv", "rerun_bigtestedset.csv")


def testManyTrials(numTrials, correctFile, testFile):
    """
    Runs however many numtrials number of trials, each with numcases
    number of patients using DS parse results, to see how the average
    percent correct varies.

    Plots the values on a chart.
    """
    correctDict = buildDict(correctFile)
    testDict = buildDict(testFile)
    accuracy = {}
    numCases = [100,200,300,400]

    for j in range(len(numCases)):#either 100, 200, 300 or 400
        accuracy[j] = []
        for trial in range(numTrials):
            wrongPts = []
            numCorrect = 0
            for i in range(numCases[j]):
                value = random.choice(testDict.keys())
                if testDict[value] == correctDict[value]:
                    numCorrect += 1
                else:
                    wrongPts.append(value)
                accuracy[j].append(float(numCorrect)/numCases[j])
    print accuracy

    
    pylab.hist(accuracy[0], bins = 10)
    pylab.subplot(221)
    xmin, xmax = pylab.xlim()
    pylab.suptitle('Bootstrapping with 100, 200, 300, 400 Patient Samples')
    pylab.xlabel('Accuracy')
    pylab.ylabel('Number of Trials')   
    
    pylab.hist(accuracy[1], bins = 10)
    pylab.subplot(222)
    xmin, xmax = pylab.xlim()
   # pylab.subtitle('Bootstrapping with 200 Patient Samples')
    pylab.xlabel('Accuracy')
    pylab.ylabel('Number of Trials')   

    pylab.hist(accuracy[2], bins = 10)
    pylab.subplot(223)
    xmin, xmax = pylab.xlim()
   # pylab.subtitle('Bootstrapping with 300 Patient Samples')
    pylab.xlabel('Accuracy')
    pylab.ylabel('Number of Trials')   

    pylab.hist(accuracy[3], bins = 10)
    pylab.subplot(224)
    xmin, xmax = pylab.xlim()
   # pylab.subtitle('Bootstrapping with 400 Patient Samples')
    pylab.xlabel('Accuracy')
    pylab.ylabel('Number of Trials')   
    
    pylab.show()
    

