# update.sh
A (very bad) auto updater for plugins

## how use
1. create /scripts/ in server folder and move update.sh there
2. put stuff in /list.txt
3. execute /scripts/update.sh
4. profit?


## list.txt format
`<type> <repo> <cmd> <out> <dest> <branch>`  
example:
```
FETCH	https://ci.plex.us.org/job/Scissors/job/main/lastSuccessfulBuild/artifact/build/libs/Scissors-1.17.1-R0.1-SNAPSHOT.jar										server.jar
BUILD	git@github.com:AtlasMediaGroup/TotalFreedomMod.git	mvn -B clean package																	target/TotalFreedomMod.jar					plugins/TotalFreedomMod.jar				development
GHREL	PlayPro/CoreProtect																																			plugins/CoreProtect.jar
```  
use tabs not spaces (or else it won't work)
