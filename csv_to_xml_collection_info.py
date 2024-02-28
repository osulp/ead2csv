# original: csv2xml.py
# FB - 201010107
# First row of the csv file must be header!


import csv
import argparse
import os

def convert_csv_to_xml(csvFile, xmlFile):
    csvData = csv.reader(open(csvFile))
    xmlData = open(xmlFile, 'w')
    xmlData.write('<?xml version="1.0"?>' + "\n")
    xmlData.write('<collection_info>' + "\n")

    rowNum = 0
    for row in csvData:
        if rowNum == 0:
            tags = row
            # replace spaces w/ underscores in tag names
            for i in range(len(tags)):
                tags[i] = tags[i].replace(' ', '_')
        else:
            xmlData.write('<collection>' + "\n")
            for i in range(len(tags)):
                xmlData.write('    ' + '<' + tags[i] + '>' \
                              + row[i] + '</' + tags[i] + '>' + "\n")
            xmlData.write('</collection>' + "\n")

        rowNum +=1

    xmlData.write('</collection_info>' + "\n")
    xmlData.close()

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("csvFilename")
    parser.add_argument("xmlFilename")
    args = parser.parse_args()

    convert_csv_to_xml(args.csvFilename, args.xmlFilename)
