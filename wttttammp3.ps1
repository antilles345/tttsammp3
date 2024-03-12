param (
    [string]$inputFolder
)

# Function to get ID3 album tag from an MP3 file
function Get-Id3AlbumTag($mp3FilePath) {
    $shell = New-Object -ComObject Shell.Application
    $folder = $shell.Namespace((Get-Item $mp3FilePath).DirectoryName)
    $file = $folder.ParseName((Get-Item $mp3FilePath).Name)

    $albumProperty = 14  # ID3 album tag property, if you don't get the expected results, use the "read id3 tags.ps1" to examine your file structure, 21 should be the title
    $albumTag = $folder.GetDetailsOf($file, $albumProperty)

    return $albumTag
}

# Function to create a WAV file with ID3 album tag using Windows TTS engine
function Create-TtsWav($text, $outputFilePath) {
    Add-Type -AssemblyName System.Speech
    $speak = New-Object System.Speech.Synthesis.SpeechSynthesizer
    $speak.SetOutputToWaveFile($outputFilePath)
    $speak.Speak($text)
    $speak.Dispose()
}

# Function to convert WAV to MP3 using ffmpeg
function Convert-WavToMp3($inputFilePath, $outputFilePath) {
	ffmpeg -i $inputFilePath -vn -ar 44100 -ac 2 -b:a 192k -y $outputFilePath
}

# Function to convert mp3 filenames into txt file for ffmpeg concat demuxer
function Read-files-to-list($inputList, $announcement, $outputFilePath) {
	$inputList ="file `'"+$($inputList.FullName -join "`'`r`nfile `'")+"`'"
	$inputList ="file `'"+$announcement+"`'`r`n"+$inputList
	
	New-Item $outputFilePath
	Set-Content $outputFilePath $inputList -Encoding Utf8
	#Force removal of utf8 BOM to manage special characters
	$null = New-Item -Force $outputFilePath -Value (Get-Content -Raw $outputFilePath)
}


# Get the list of MP3 files in the input folder
$mp3Files = Get-ChildItem -Path $inputFolder -Filter *.mp3

# Ensure there is at least one MP3 file in the folder
if ($mp3Files.Count -eq 0) {
    Write-Host "No MP3 files found in the input folder."
    exit
}

# Set input
$inputFolder = Get-Location

# Get ID3 album tag from the first MP3 file
$firstMp3File = $mp3Files[0].FullName
$albumTag = Get-Id3AlbumTag -mp3FilePath $firstMp3File

# Create a temporary WAV file with the album tag
$tempWavFile = Join-Path -Path $inputFolder -ChildPath "temp.wav"
Create-TtsWav -text $albumTag -outputFilePath $tempWavFile

# Convert the WAV file to MP3 using ffmpeg
$tempMp3File = Join-Path -Path $inputFolder -ChildPath "temp.mp3"
Convert-WavToMp3 -inputFilePath $tempWavFile -outputFilePath $tempMp3File

# Create a temporary txt file with the mp3 filenames
$tempTxtFile = Join-Path -Path $inputFolder -ChildPath "temp.txt"
read-files-to-list -inputList $mp3Files -announcement $tempMp3File -outputFilePath $tempTxtFile

# Get the parent directory of the input folder
$parentDirectory = Get-Item $inputFolder | Get-Item -Force | Split-Path -Parent

# Use ffmpeg to merge the temporary MP3 file with all input files
$outputFileName = $albumTag + ".mp3"
$outputFilePath = Join-Path -Path $parentDirectory -ChildPath $outputFileName
ffmpeg -f concat -safe 0 -i $tempTxtFile -i $mp3Files[0].FullName -map_metadata 1 -metadata title=$albumTag $outputFilePath


# Remove temporary files
Remove-Item $tempWavFile
Write-Host 'removed temporary WAV File'
Remove-Item $tempMp3File
Write-Host 'removed temporary MP3 File'
Remove-Item $tempTxtFile
Write-Host 'removed temporary txt File'

# Wait for user confirmation to exit, uncomment for debugging
# Read-Host -Prompt "Press Enter to exit"
