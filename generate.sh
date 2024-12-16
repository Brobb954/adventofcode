#!/bin/bash

usage() {
  echo "Usage: $0 <year> <day>"
  echo "Example: $0 2024 1"
  exit 1
}

get_input() {
  local year=$1
  local day=$2
  local day_padded=$(printf "%02d" "$day")

  curl -s --cookie "session=$AOC_SESSION" "https://adventofcode.com/${year}/day/${day}/input" >"./year$year/day$day_padded/input.txt"

  if [ $? -ne 0 ] || [ ! -s "./year${year}/day${day_padded}/input.txt" ]; then
    echo "Failed to fetch input"
    exit 1
  fi
}

create_day_solution() {
  local year=$1
  local day=$2
  local day_padded=$(printf "%02d" "$day")

  cat >"./year${year}/day${day_padded}/solution.go" <<EOS
  package day$day_padded

  import (
  "os"
  _ "embed"
  )

  //go:embed input.txt
  var file embed.FS


  func Part1(testInput string) int {

    if testInput != "" {
      // TODO: Create solution
    }
    input, _ := file.Readfile("input.txt")
    // TODO: Create Solution

    return 0
  }

  func Part2() int {
    input, _ := input.Readfile("input.txt")

    TODO: "Create Solution"
    return 0
  }

EOS
}

create_air_toml() {
  local year=$1
  local day=$2
  local day_padded=$(printf "%02d" "$day")

  cat >"./year$year/.air.toml" <<EOS

  root = "."
  tmp_dir = "tmp"

  [build]
  cmd = "go build -o ./tmp/main ."

  bin = "./tmp/main"
  full_bin = "./tmp/main ${day_padded}"

  include_ext = ["go"]
  exclude_dir = ["tmp"]

  delay = 1000

  [log]
  time = true

  [screen]
  clear_on_rebuild = true

EOS
}

create_main() {
  local year=$1
  local day=$2

  cd year$year

  go mod init year$year

  cat >"main.go" <<EOS

  package main

  import (
  "os"
  "fmt"
  )

  func main() {

    if len(os.Args) == 2 {
      day := os.Args[1]

      testInput := ""

      expectedOutput := 0

      if testInput != "" {
        fmt.Println("Running test input")
        result := day01.Part1(testInput)
        if result != expectedOutput {
          fmt.Printf("Failed: Expected %v, Got: %v\n", expectedOutput, result)
          return
        }
        fmt.Println("Test Passed")
      }
      return
    }

    if len(os.Args) == 3 {
      day := os.Args[1]
      part := os.Args[2]

      switch part {
        case "1":
          runPart1(day)
        case "2":
          runPart2(day)
        default:
          fmt.Println("There are only two parts")
      }

      return
    }

    fmt.Println("Usage: main <day> [part]")
  }

  func runPart1(day string) {
  day := fmt.Sprintf("day%v", day)
  fmt.Printf("Part 1: %v", day.Part1(""))
  }

    func runPart2(day string) {
  day := fmt.Sprintf("day%v", day)
  fmt.Printf("Part 2: %v", day.Part2(""))
  }

EOS

}

#
#
# change nested ifs to linear
#
#
#

main() {

  if [ $# -ne 2 ]; then
    usage
  fi

  year=$1
  day=$2
  day_padded=$(printf "%02d" "$day")

  if [ -d "./year$year/day$day_padded" ]; then
    if [ -f "./year$year/main.go" ]; then
      if [ -f "./year$year/.air.toml" ]; then
        if [ -f "./year$year/day$day_padded/solution.go" ]; then
          if [ -f "./year$year/day$day_padded/input_$day_padded.txt" ]; then
            echo "This is already set up, try another day"
          else
            get_input $year $day
          fi
        else
          create_day_solution $year $day
        fi
      else
        create_air_toml $year $day
      fi
    else
      create_main $day
    fi
  else
    mkdir -p ./year$year/day$day_padded
  fi

}
