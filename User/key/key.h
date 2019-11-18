#ifndef KEY_H
#define KEY_H
#include "mh523.h"
#include "mhscpu.h"
#include "delay.h"


#define KEY_LONG_DOWN_DELAY 100

typedef enum _KEY_STATUS_LIST
{
    KEY_NULL = 0x00,//�޼�����
    KEY_SURE = 0x01,//ȷ��̬
    KEY_UP   = 0x02,//̧��
    KEY_DOWN = 0x04,//����
    KEY_LONG = 0x08,//����
} KEY_STATUS_LIST;

typedef enum _KEY_LIST
{
    KEY0=0,
    KEY1,
    KEY2,
    KEY3,
    KEY4,
    KEY5,
    KEY_NUM,
} KEY_LIST;

typedef struct _KEY_COMPONENTS
{
    unsigned char KEY_SHIELD;       //��������0:���Σ�1:������
    unsigned int  KEY_COUNT;        //������������
    unsigned char KEY_LEVEL;        //���⵱ǰIO��ƽ������1��̧��0
    unsigned char KEY_DOWN_LEVEL;   //����ʱIOʵ�ʵĵ�ƽ
    unsigned char KEY_STATUS;       //����״̬
    unsigned char KEY_EVENT;        //�����¼�
    unsigned char (*READ_PIN)(void);//��IO��ƽ����
} KEY_COMPONENTS;
extern KEY_COMPONENTS Key_Buf[KEY_NUM];


void key_init();//����IO�ڳ�ʼ��
void Task_KEY_Scan(void);
unsigned char GetKey();
#endif


