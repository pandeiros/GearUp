#include <iostream>
#include <fstream>
#include <string>

using namespace std;

template<typename ... Args>
std::string string_format(const std::string& format, Args ... args)
{
    int size_s = std::snprintf(nullptr, 0, format.c_str(), args ...) + 1; // Extra space for '\0'
    if (size_s <= 0) { throw std::runtime_error("Error during formatting."); }
    auto size = static_cast<size_t>(size_s);
    std::unique_ptr<char[]> buf(new char[size]);
    std::snprintf(buf.get(), size, format.c_str(), args ...);
    return std::string(buf.get(), buf.get() + size - 1); // We don't want the '\0' inside
}

int main()
{
    // Vanilla
    const int RANGES = 5;
    int ranges[RANGES][2] = {
        { 0, 24358 },
        { 122270, 122270 },
        { 122284, 122284 },
        { 172070, 172070 },
        { 180000, 192000 }
    };
    const string link = "https://classic.wowhead.com/item=";
    const string filename = "all_links_vanilla.txt";

    // TBC
    //const int RANGES = 5;
    //int ranges[RANGES][2] = {
    //    { 0, 40000 },
    //    { 43516, 43516 },
    //    { 180089, 180089 },
    //    { 184000, 192000 },
    //    { 194101, 194101 }
    //};
    //const string link = "https://tbc.wowhead.com/item=";
    //const string filename = "all_links_tbc.txt";

    // Wrath
    //const int RANGES = 9;
    //int ranges[RANGES][2] = {
    //    { 0, 54000 },
    //    { 56806, 56806 },
    //    { 122270, 122270 },
    //    { 122284, 122284 },
    //    { 172070, 172070 },
    //    { 180089, 180089 },
    //    { 184800, 185000 },
    //    { 185600, 199000 },
    //    { 199000, 200000 }
    //};
    //const string link = "https://www.wowhead.com/wotlk/item=";
    //const string filename = "all_links_wrath.txt";

    ofstream fileStream;
    fileStream.open(filename);
    if (!fileStream.is_open())
    {
        cout << "Cannot open file.";
        return 0;
    }

    for (int rangeIndex = 0; rangeIndex < RANGES; ++rangeIndex)
    {
        for (int i = ranges[rangeIndex][0]; i <= ranges[rangeIndex][1]; ++i)
        {
            fileStream << string_format("%s%d\n", link.c_str(), i);
        }
    }

    return 0;
}