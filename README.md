Windows TonUINO Text To Speech And Merge MP3

-- Description
  1. A Windows Powershell Script to Merge a group of mp3 files in a folder into one single file and adding an announcement at the front of the resulting mp3 File.
  2. Uses the windows built in tts functions, doesn't rely on AI or cloud subscriptions. Results are therefore merely functional.
  3. Reencodes, therefore results may be affected by quality loss.

-- Requirements
  1. FFMPEG needs to be installed and Correctly configured in the System Variables.

-- Usage:
  1. Place the wtttsammp3.ps1 into the folder with the mp3 files you want to merge. Though I suggest you try it on a seperate copy first to ensure the results are as you epxect them to be.
  2. Right Click, choose "run with powershell"

-- Behaviour
  1. The script will create 3 temporary files, which will be deleted during runtime
    a) temp.wav text to speech announcement using the ID3 Albm information of the first mp3 File in the folder
    b) temp.mp3 reencoded by ffmpeg from temp.wav
    c) temp.txt list of all mp3 files (including the announcement) in the folder
  2. FFMPEG will reencode all listed files into a single mp3 with the album name of the original first file as filename and title information. all other tags will be retained from the original first file
  3. The ouput file will be the input folder's parent directory
  4. The original files will be retained unchanged
