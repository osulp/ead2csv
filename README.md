
# EAD2CSV: An XSL Transformation

The core of this repository is an XSLT 2.0 stylesheet which extracts the contents of specified elements from Encoded Archival Description (EAD) XML archival finding aids, at the collection level and for each component description, and outputs the data to a tabular data text format (CSV). It focuses on the Archival Description (`archdesc` metadata delements)

Rendering finding aid data in a tabular, plain text format makes it more accessible to archives staff who may review, sort, filter, and otherwise manipulate the corpus as a whole using familiar tools. As an added benefit, it also makes it accessible as plain text for computational analysis using a variety of tools. 

## Setup

### EAD XML Files

The use case for which this stylesheet was developed was based on EAD XML files exported from Archon, with one collection per XML file, and with the XML files named using the numeric Archon ID (e.g. 1042.xml). While not (knowingly) limited to Archon EAD, the stylesheet does expect a similar starting point:

- EAD XML files are located in a single directory
- Each EAD XML file represents one archival collection
- Each collection has a unique identifier
- EAD files are named using the convention {identifier}.xml
- EAD XML files validate according to the [EAD 2002 W3C Schema](http://www.loc.gov/ead/ead.xsd)


### Collection Information reference document

The main EAD to CSV stylesheet can fetch data from a separate XML document listing archival collection management data located outside of the EAD finding aids. The unique collection identifier (in the case of SCARC collections, the Archon ID) is used as the key, and the data fields that are used by the XSLT are `description_level` and `collection_type`. 

If this extra collection information exists in CSV format, then the Python script `csv_to_xml_collection_info.py` can be used to transform the CSV data to XML in the structure expected by the EAD to CSV stylesheet. The CSV should use the field names / column headers `identifier`, `description_level`, and `collection_type` -- or, provide the field names / column headers matching the CSV as parameters when processing `ead2csv.xsl`. Note that the Python script will replace any spaces in column headers with underscore characters. 

To run with Python, execute the command:  
`python csv_to_xml_collection_info.py {path/source_CSV_filename} collection_info.xml`

For example,  
`python csv_to_xml_collection_info.py scarc_collection_info.csv collection_info.xml`

The output of this script should look like:

```
<collection_info>
...
  <collection>
    <identifier>1042</identifier>
    <description_level>CLD</description_level>
    <collection_type>MSS</collection_type>
  </collection>
...
</collection_info>
```

This Python script was adapted with gratitude from https://code.activestate.com/recipes/577423-convert-csv-to-xml/.

## Transforming EAD XML to CSV

A number of parameters may be updated by the user to suit local needs including CSV formatting characters, filenames and paths, and Collection Information document details. These can be edited directly in the XSLT or passed as arguments at the command line; refer to the `ead2csv.xsl` file for specifics.

The logic of this stylesheet is explicit. The list of included EAD elements is provided in the field mapping below. Elements may be edited to suit the user's needs. Elements can be excluded by commenting out the relevant lines of code, and additional elements may be added where missing. Note that to update the included fields, they must be added or removed in three locations: the header row, the collection row logic, and the component row logic.

To transform EAD XML with this stylesheet, the user may run in an XSLT processing application such as Oxygen, or use a command line tool such as Saxon. The stylesheet specifies the directory of source files as well as the output filename internally, so the XSL file may be specified as its own input. If using Saxon, the command will look something like:

`java -jar saxon.jar -s:ead2csv.xsl -xsl:ead2csv.xsl -o:finding_aid_data.csv` 

## EAD element to CSV field mapping

{coming soon}
