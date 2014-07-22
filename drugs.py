### Code to parse drugs output
import csv

def readDrugs(filename):
    """parses the file in filename to output a list
    of the unique drugs mentioned in the file
    """
    dataFile = open(filename, "r")
    lines=[]
    for line in dataFile.readlines():
        lines.append(line.strip())
    drugsList = []
    for line in lines:
        cur = line.split(",")
        if cur[2] not in drugsList:
            drugsList.append(cur[2])
    print drugsList
    return drugsList

#readDrugs("BB.csv")
#readDrugs("CCB.csv")
#readDrugs("DMrx.csv")

def outputDrugData(filename, List):
    """
    will output a csv file containing the pat ids and whether they
    are taking each drug in list
    """

    data = {}
    dataFile = open(filename, "r")
    lines = []
    drugs = {}
    for i in range(0,len(List)):
        drugs[List[i]] = i
    
    for line in dataFile.readlines():
        lines.append(line.strip())
    for line in lines:
        cur = line.split(",")
        if cur[1] in data.keys():
            data[cur[1]]
            data[cur[1]].pop(drugs[cur[2]])
            data[cur[1]].insert(drugs[cur[2]], "1")
        else:
            data[cur[1]] = ["0"]*len(List)
            data[cur[1]].pop(drugs[cur[2]])
            data[cur[1]].insert(drugs[cur[2]], "1")

    for key in data.keys():
        #key, string of 0s and 1s corresponding to values in columns in order
        print key+","+",".join(data[key])+","

outputDrugData("DMrx.csv", readDrugs("DMrx.csv"))
