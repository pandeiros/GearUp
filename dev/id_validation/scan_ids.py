import requests
import re
import sys

# ---------------------------------------------------

def printUsage():
    print("Invalid/missing argument! Usage: scan_ids.py -vanilla | -tbc | -wrath")
    quit()

def checkDeprecated(response):
    result = "]Deprecated[" in response.text or ">This item is not available to players.<" in response.text
    return result

def checkRandomEnch(response):
    beginning = '<h2 class="heading-size-3">Random Enchantments</h2>'
    end = '<div style="clear: left"></div>'
    startPos = response.text.find(beginning)
    if (startPos == -1):
        return False

    endPos = response.text.find(end, startPos + len(beginning), len(response.text))
    if (endPos == -1):
        return False

    if (startPos >= endPos):
        return False

    return True

# ---------------------------------------------------

if (len(sys.argv) < 1):
    printUsage()

version = sys.argv[1]
inFilename = ""
outFilename = ""
depFilename = ""
randEnchFilename = ""

# Check version
if (version == "-vanilla"):
    inFilename = "../link_generation/all_links_vanilla.txt"
    outFilename = "valid_ids_vanilla.txt"
    depFilename = "deprecated_ids_vanilla.txt"
    randEnchFilename = "random_ench_ids_vanilla.txt"
elif (version == "-tbc"):
    inFilename = "../link_generation/all_links_tbc.txt"
    outFilename = "valid_ids_tbc.txt"
    depFilename = "deprecated_ids_tbc.txt"
    randEnchFilename = "random_ench_ids_tbc.txt"
elif (version == "-wrath"):
    inFilename = "../link_generation/all_links_wrath.txt"
    outFilename = "valid_ids_wrath.txt"
    depFilename = "deprecated_ids_wrath.txt"
    randEnchFilename = "random_ench_ids_wrath.txt"
else:
    printUsage()

# inFilename = "test.txt"

# Prepare files
fileValidIDs = open(outFilename, "w")
fileValidIDs.close()
fileDeprecatedIDS = open(depFilename, "w")
fileDeprecatedIDS.close()
fileRandEnchIDs = open(randEnchFilename, "w")
fileRandEnchIDs.close()

# Now open in "a" mode
fileValidIDs = open(outFilename, "a")
fileDeprecatedIDS = open(depFilename, "a")
fileRandEnchIDs = open(randEnchFilename, "a")

p = re.compile("item=(\d+)")
count = 0
validCount = 0
depCount = 0
randEnchCount = 0

with open(inFilename, "r") as f:
    for line in f:
        response = requests.get(line)
        
        # Found ID in the Wowhead database
        if (response.url.find('notFound') == -1):
            result = p.search(response.url)
            id = result.group(1)

            hasRandEnch = False
            isDep = checkDeprecated(response)
            if (isDep):
                fileDeprecatedIDS.write(id,)
                fileDeprecatedIDS.write(', ')
                depCount = depCount + 1
                if (depCount % 25 == 0):
                    fileDeprecatedIDS.write("\n")
            else:
                fileValidIDs.write(id,)
                fileValidIDs.write(', ')
                validCount = validCount + 1
                if (validCount % 25 == 0):
                    fileValidIDs.write("\n")

                hasRandEnch = checkRandomEnch(response)
                if (hasRandEnch):
                    fileRandEnchIDs.write(id,)
                    fileRandEnchIDs.write(', ')
                    randEnchCount = randEnchCount + 1
                    if (randEnchCount % 25 == 0):
                        fileRandEnchIDs.write("\n")

            count = count + 1

            if (isDep):
                print(id, ' - deprecated')
            else:
                if (hasRandEnch):
                    print(id, ' - random enchantment')
                else:
                    print(id)

            # Saving every 50 ids just to sure
            if (count % 50 == 0):
                fileValidIDs.close()
                fileValidIDs = open(outFilename, "a")
                fileDeprecatedIDS.close()
                fileDeprecatedIDS = open(depFilename, "a")
                fileRandEnchIDs.close()
                fileRandEnchIDs = open(randEnchFilename, "a")

        response.close()

fileValidIDs.close()
fileDeprecatedIDS.close()
fileRandEnchIDs.close()