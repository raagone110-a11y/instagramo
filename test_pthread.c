#include <pthread.h>

int main(void) {
    pthread_atfork(0, 0, 0);
    return 0;
}
