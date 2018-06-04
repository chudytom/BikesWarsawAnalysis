using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;

namespace IT4U
{
    internal static class Program
    {
        private static void Main()
        {
            ProcessFiles("./Data/csvResults");
            ProcessFiles("./Data/weekendCsvResults");
        }

        private static void ProcessFiles(string path)
        {
            var files = Directory.GetFiles(path);
            var ret = new Dictionary<string, List<double[]>>[3][];
            var coordinatesToAddress = new Dictionary<string, string>();

            NumberFormatInfo provider = new NumberFormatInfo();
            provider.NumberDecimalSeparator = ".";
            provider.NumberGroupSeparator = ".";
            provider.NumberGroupSizes = new int[] { 3 };
            var colorsDict = new Dictionary<int, string>();
            colorsDict.Add(1, "black");
            colorsDict.Add(2, "red");
            colorsDict.Add(3, "forestgreen");
            colorsDict.Add(4, "darkolivegreen3");

            var bestTransportOptionsValues = new StringBuilder();

            for (var i = 0; i < ret.Length; i++)
            {
                ret[i] = new Dictionary<string, List<double[]>>[2];
                for (var j = 0; j < ret[i].Length; ++j) ret[i][j] = new Dictionary<string, List<double[]>>();
            }
            foreach (var file in files)
            {
                var lines = File.ReadLines(file);
                var dayTimeType =
                    file.Split(' ')[1].StartsWith("07") || file.Split(' ')[1].StartsWith("08") ? 0 :
                    file.Split(' ')[1].StartsWith("12") || file.Split(' ')[1].StartsWith("13") ? 1 : 2;
                foreach (var line in lines.Skip(1))
                {
                    var splittedLine = new Regex("((?<=\")[^\"]*(?=\"(,|$)+)|(?<=,|^)[^,\"]*(?=,|$))").Matches(line);
                    var destType = splittedLine[1].ToString().StartsWith("rondo") ? 0 : 1;
                    var arr = new double[7];
                    for (var i = 0; i < 7; ++i)
                        arr[i] = splittedLine[i + 4].ToString() != "NA" ?
                            double.Parse(splittedLine[i + 4].ToString(), provider) : -1.0;
                    if (!ret[dayTimeType][destType].ContainsKey(splittedLine[3].ToString()))
                    {
                        ret[dayTimeType][destType].Add(splittedLine[3].ToString(), new List<double[]>());
                        if (!coordinatesToAddress.ContainsKey(splittedLine[3].ToString()))
                            coordinatesToAddress.Add(splittedLine[3].ToString(), splittedLine[2].ToString());
                    }
                    ret[dayTimeType][destType][splittedLine[3].ToString()].Add(arr);
                }
            }
            for (var i = 0; i < ret.Length; ++i)
            {
                for (var j = 0; j < ret[i].Length; ++j)
                {
                    var fileName =
                        (path.Contains("weekend") ? "weekend_" : "") +
                        (i == 0 ? "07-09_" : i == 1 ? "12-14_" : "16-18_") +
                        (j == 0 ? "Rondo-ONZ" : "Domaniewska");
                    var valuesFileName = fileName + "_Values";
                    fileName += ".csv";
                    valuesFileName += ".txt";
                    var lines = new List<string> { ",Region,,Rower,Auto,Transport Miejski,Najkorzystniej" };
                    var iterator = 0;
                    foreach (var e in ret[i][j])
                    {
                        ++iterator;
                        var avgBicycle = ret[i][j][e.Key].Where(item => Math.Abs(item[4] - -1) > 0.001).Average(item => item[4]);
                        var avgCar = ret[i][j][e.Key].Where(item => Math.Abs(item[1] - -1) > 0.001).Average(item => item[1]);
                        var avgBus = ret[i][j][e.Key].Any(item => Math.Abs(item[6] - -1) > 0.001) ?
                            ret[i][j][e.Key].Where(item => Math.Abs(item[6] - -1) > 0.001).Average(item => item[6]) : -1;
                        // 1 samochód
                        // 2 transport publiczny
                        // 3 rower
                        // 4 rower +5 minut
                        var best = "Rower"; // rower
                        var bestValue = 3;
                        if (avgCar < avgBicycle)
                        {
                            if (avgCar < avgBus || Math.Abs(avgBus - -1) < 0.001)
                            {
                                best = "Samochód";
                                bestValue = 1;
                            }
                            else if (avgBus < avgBicycle && Math.Abs(avgBus - -1) > 0.001)
                            {
                                best = "Transport Publiczny";
                                bestValue = 2;
                            }
                        }
                        else if (avgBus < avgBicycle && Math.Abs(avgBus - -1) > 0.001)
                        {
                            best = "Transport Publiczny";
                            bestValue = 2;
                        }

                        if(bestValue != 3)
                        {
                            if(avgBicycle < avgCar + 5 && avgBicycle < avgBus + 5)
                            {
                                best = "Rower porównywalnie szybki";
                                bestValue = 4;
                            }
                        }

                        var str = iterator + "," + coordinatesToAddress[e.Key].Split(',')[0] + ",Czas," +
                                  avgBicycle.ToString(provider) + "," + avgCar.ToString(provider) + "," + avgBus.ToString(provider) + "," + best;
                        lines.Add(str.Replace("-1", "NA"));
                        str = ",,Dystans," +
                              ret[i][j][e.Key].Where(item => Math.Abs(item[3] - -1) > 0.001).Average(item => item[3]).ToString(provider) + "," +
                              ret[i][j][e.Key].Where(item => Math.Abs(item[0] - -1) > 0.001).Average(item => item[0]).ToString(provider) + "," +
                              (ret[i][j][e.Key].Any(item => Math.Abs(item[5] - -1) > 0.001) ?
                                ret[i][j][e.Key].Where(item => Math.Abs(item[5] - -1) > 0.001).Average(item => item[5]).ToString(provider) : "-1");
                        lines.Add(str.Replace("-1", "NA"));
                        bestTransportOptionsValues.Append($"\"{colorsDict[bestValue]}\",");
                    }
                    File.WriteAllLines(fileName, lines, Encoding.UTF8);
                    File.WriteAllText(valuesFileName, bestTransportOptionsValues.ToString());
                    bestTransportOptionsValues.Clear();
                }
            }
        }
    }
}
