######Author: SusanCav
import numpy as np
import random
import pylab
#import scipy.stats
#import statistics

def readResults(filename, neonates):
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
    IDnums = {"CPeriOnly":[], "CBoth": [], "CNeither":[],"CPulmOnly":[], "MIPeriOnly":[],
              "MIPulmOnly":[], "MINoKnownPeri":[], "MINoKnownPulm":[], "MINeither":[]}
    MissingInfo = {"PeriOnly":0, "PulmOnly":0, "NoKnownPeri":0, "NoKnownPulm":0, "Neither":0}
    MissingExam = []
    MissingHistory = 0
    for line in lines:
        cur = line.split(",")
        if cur[0] not in neonates.keys():
            if cur[3] == '-1':
                MissingHistory += 1
                MissingExam.append(cur[0])
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
##    print Counts, MissingInfo, MissingHistory
##    randomsample = []
##    5
##    for i in range(100):
##        value = random.choice(MissingExam)
##        randomsample.append(value)
##    print randomsample    
##    return Counts, MissingInfo, MissingHistory
    return Counts, MissingInfo, MissingHistory
#readResults("dsfullsetoutput.csv")

##Results:
##Counts({'Both': 838, 'Neither': 12705, 'PeriOnly': 2011, 'PulmOnly': 1904})
##MissingInfo({'PulmOnly': 137, 'PeriOnly': 52, 'NoKnownPulm': 1512,
##'Neither': 724, 'NoKnownPeri': 762})
## No History: 5377

def removeNeonates(file1):
    dataFile = open(file1, "r")
    lines=[]
    for line in dataFile.readlines():
        lines.append(line.strip())
    addendums = 0
    neonates = {}
    for line in lines:
        cur = line.split(",")
        neonates[cur[2]] = "1"
    return neonates

        

def getAverage(file1):
    """
    Reads full length chart (for looking at Joon's data along with edema)
    """
#AGE_FIRST_ICUSTAY
#GENDER
#FIRST_ICU_LOS
#ICUSTAY_FIRST_SERVICE
#FIRST_ICUSTAY_ADMIT_SAPS
#VASOPRESSOR_FIRST_ICUSTAY
#TOTAL_SAPS_FIRST_ICUSTAY
    dataFile = open(file1, "r")
    lines=[]
    for line in dataFile.readlines():
        lines.append(line.strip())
    addendums = 0
    data = {}
    for line in lines:
        cur = line.split(",")
        curvalues = {}
        curvalues["pulm"] = cur[1]
        curvalues["peri"] = cur[2]
        curvalues["exam"] = cur[3]
        data[cur[0]] = curvalues
##      
##    dataFile = open(file2, "r")
##    lines=[]
##    for line in dataFile.readlines():
##        lines.append(line.strip())
##    addendums = 0
##    for line in lines:
##        cur = line.split(",")
##        
##        try:
##            current = data[cur[0]]
##          #  print cur
##          #  print data["2075"]
##            current["ICU_Mort"] = cur[4]
##            current["Service"] = cur[12]
##            current["Age"] = float(cur[8])
##            current["Gender"] = cur[9]
##            current["Race"] = cur[10]
##            current["LOS"]= float(cur[11])
##            current["ninezeroMort"] = cur[20] #not sure
##            try:
##                current["SAPS"] = float(cur[13])
##            except ValueError:
##                continue
##            data[cur[0]] = current
##        except KeyError:
##            continue
##    #make sure this works okay
    return data
# removeNeonates("export.csv")
print readResults("dsfullsetoutput (2).csv", removeNeonates("export.csv"))



def evalData(data):
    gender = {'M': 0, 'F': 0}
    service = {'MICU':0, 'CCU':0}
    age = []
    race = {}
    los = []
    SAPS = []
    ICU_mort = {'Y':0, 'N':0}
    pulm = {'0':0,'1':0}
    ngender = {'M': 0, 'F': 0}
    nservice = {'MICU':0, 'CCU':0}
    nage = []
    nrace = {}
    nlos = []
    nSAPS = []
    nICU_mort = {'Y':0, 'N':0}
    npulm = {'0':0,'1':0}
    
    for key in data.keys():
        if data[key]['exam'] != '-1':
            cur = data[key]
            try:
                if cur['peri'] == '1':
                    gender[cur['Gender']] += 1
   #             service[cur['Service']] += 1
                    age.append(cur['Age'])
  #              race[cur['Race']] += 1
                    los.append(cur['LOS'])
                    try:
                        SAPS.append(cur['SAPS'])
                    except KeyError:
                        continue
                    ICU_mort[cur['ICU_Mort']] +=1
                    pulm[cur['pulm']] +=1
                elif cur['peri'] == '0':
                    ngender[cur['Gender']] += 1
   #             nservice[cur['Service']] +=1
                    nage.append(cur['Age'])
   #             nrace[cur['Race']] +=1
                    nlos.append(cur['LOS'])
                    try:
                        nSAPS.append(cur['SAPS'])
                    except KeyError:
                        continue
                    nICU_mort[cur['ICU_Mort']] +=1
                    npulm[cur['pulm']] +=1
            except KeyError:
                continue
        
    print np.average(age)
    print np.std(age)
    print len(age)

    print np.average(nage)
    print np.std(nage)
    print len(nage)
            
#evalData(getAverage("dsfullsetoutput (2).csv","revisedMIMICII.csv"))          
        
##        ###Get Avg Age
##        print cur[12]
##        if cur[2] == "1":
##                hasedema.append(float(cur[12]))
##        elif cur[2] == "0":
##                noedema.append(float(cur[12]))
##    age_edema = numpy.average(hasedema)
##    age_noedema = numpy.average(noedema)
##
##    print scipy.stats.ttest_ind(noedema, hasedema)
##
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
#readAddendums("addendum_data.txt")
        
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
    

