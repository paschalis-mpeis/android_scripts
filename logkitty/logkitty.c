#include <stdio.h>
#include <stdlib.h>
#include <android/log.h>

#define LOG(DEBUG_LVL,LOG_TAG,...) __android_log_print((DEBUG_LVL), (LOG_TAG), __VA_ARGS__)

//Prototypes
void show_usage();
int get_debug_level(char);

/**
 * @brief  A simple utility that prints output on logcat.
 * It is installed on /system/bin/ using make install
 *
 * @param argc
 * @param argv[]
 *
 * @return 
 */
int main(int argc, char *argv[]){

  if(argc!=4){
    show_usage();
  }

  char* tag = argv[1];
  int debugLevel = get_debug_level(argv[2][0]);
  char* msg = argv[3];

  LOG(debugLevel, tag, "%s", msg);

  return 0;
}



/**
 * @brief Choose the appropriate debug level based on the character given
 *
 * @param d
 *
 * @return 
 */
int get_debug_level(char d){

  switch (d) {
    case 'D':
      return ANDROID_LOG_DEBUG;
      break;
    case 'I':
      return ANDROID_LOG_INFO;
      break;
    case 'E':
      return ANDROID_LOG_ERROR;
    case 'W':
      return ANDROID_LOG_WARN;
      break;
    default:
      printf("Unnown log level given\n");
      exit(-1);
  }

}



/**
 * @brief Print the usage and exit
 */
void show_usage(){
  printf("Usage: <TAG> <LEVEL> \"quoted msg\"\n");
  printf("Example:\n");
  printf("mytag D \"My debug message\"\n");
  printf("\nLEVELS:\n");
  printf("W: Warning\n");
  printf("D: Debug\n");
  printf("I: Info\n");
  printf("E: Error\n");

  exit(-1);
}
