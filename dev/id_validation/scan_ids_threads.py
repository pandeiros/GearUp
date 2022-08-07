import requests
import re
import sys
import threading
import time

# ---------------------------------------------------

THREAD_COUNT = 30

allLinks = []
mutex = False

def printUsage():
    print("Invalid/missing argument! Usage: scan_ids.py -vanilla | -tbc | -wrath")
    quit()

def checkDeprecated(response):
    result = "]Deprecated[" in response.text or ">This item is not available to players.<" in response.text
    return result

def checkRandomEnch(response):
    beginning = '<h2 class="heading-size-3">Random Enchantments</h2>'
    middle = '</div><div class="random-enchantments"><ul>'
    end = '</div><div style="clear: left"></div>'

    startPos = response.text.find(beginning)
    if (startPos == -1):
        return False

    middlePos = response.text.find(middle)
    if (middlePos == -1):
        end = '</ul>'

    endPos = response.text.find(end, startPos + len(beginning), len(response.text))
    if (endPos == -1):
        return False

    if (startPos >= endPos):
        return False

    return True

def prepareLinksForThreads(filename):
    for i in range (0, THREAD_COUNT):
        newArray = []
        allLinks.append(newArray)

    currentIndex = 0
    with open(filename, "r") as f:
        for line in f:
            allLinks[currentIndex].append(line)
            currentIndex = (currentIndex + 1) % THREAD_COUNT

validIDs = []
deprecatedIDs = []
randEnchIDs = []
threadCount = 0

def scanIDs(threadIndex):
    p = re.compile("item=(\d+)")
    global threadCount
    threadCount += 1

    for link in allLinks[threadIndex]:
        response = requests.get(link)

        while(mutex):
            print("----- Thread ", threadIndex, " sleeping...")
            time.sleep(3)
        
        # Found ID in the Wowhead database
        if (response.url.find('notFound') == -1):
            result = p.search(response.url)
            id = result.group(1)

            hasRandEnch = False
            isDep = checkDeprecated(response)
            if (isDep):
                deprecatedIDs.append(id)
            else:
                validIDs.append(id)

                hasRandEnch = checkRandomEnch(response)
                if (hasRandEnch):
                    randEnchIDs.append(id)

            if (isDep):
                print(id, ' - deprecated')
            else:
                if (hasRandEnch):
                    print(id, ' - random enchantment')
                else:
                    print(id)

        response.close()

    threadCount -= 1

inFilename = ""
outFilename = ""
depFilename = ""
randEnchFilename = ""

def saveIDs():
    time.sleep(5)

    global threadCount
    global mutex

    while (threadCount > 0):
        time.sleep(20)

        validCount = 0
        depCount = 0
        randEnchCount = 0

        mutex = True
        print("---------- Saving ----------")

        sortedValidIDs = sorted([int(x) for x in validIDs])
        sortedDeprecatedIDs = sorted([int(x) for x in deprecatedIDs])
        sortedRandEnchIDs = sorted([int(x) for x in randEnchIDs])

        fileValidIDs = open(outFilename, "w")
        fileDeprecatedIDS = open(depFilename, "w")
        fileRandEnchIDs = open(randEnchFilename, "w")

        for i in range(0, len(sortedValidIDs)):
            id = sortedValidIDs[i]
            fileValidIDs.write(str(id))
            fileValidIDs.write(', ')

            validCount = validCount + 1
            if (validCount % 25 == 0):
                fileValidIDs.write("\n")

        for i in range(0, len(sortedDeprecatedIDs)):
            id = sortedDeprecatedIDs[i]
            fileDeprecatedIDS.write(str(id))
            fileDeprecatedIDS.write(', ')

            depCount = depCount + 1
            if (depCount % 25 == 0):
                fileDeprecatedIDS.write("\n")

        for i in range(0, len(sortedRandEnchIDs)):
            id = sortedRandEnchIDs[i]
            fileRandEnchIDs.write(str(id))
            fileRandEnchIDs.write(', ')

            randEnchCount = randEnchCount + 1
            if (randEnchCount % 25 == 0):
                fileRandEnchIDs.write("\n")

        fileValidIDs.close()
        fileDeprecatedIDS.close()
        fileRandEnchIDs.close()

        mutex = False

        print("---------- SAVED! ----------")

# ---------------------------------------------------

if (len(sys.argv) < 1):
    printUsage()

version = sys.argv[1]

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

# Prepare files
fileValidIDs = open(outFilename, "w")
fileValidIDs.close()
fileDeprecatedIDS = open(depFilename, "w")
fileDeprecatedIDS.close()
fileRandEnchIDs = open(randEnchFilename, "w")
fileRandEnchIDs.close()

prepareLinksForThreads(inFilename)

# Start threads
for i in range(0, THREAD_COUNT):
    x = threading.Thread(target=scanIDs, args=(i,))
    x.start()

x = threading.Thread(target=saveIDs)
x.start()