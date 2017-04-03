//**********************
// getIR.c for Raspberry Pi
//
// (C)Copyright 2015 All rights reserved by Y.Onodera
// http://einstlab.web.fc2.com
//**********************

// ---------------------
// Modified by Oyakodon <oykdn@oykdn.com>
// for Apple Pi Controller(https://github.com/oyakodon/apple-pi-ctrl).
// ---------------------

#include <stdio.h>
#include <wiringPi.h>

#define IR_LIMITS  64  // bytes buffer = IR_LIMITS x8 bits
#define AEHA 19
#define NEC 22
#define SONY 23

unsigned char countHigh();
unsigned char countLow();
void getIR2();
void getIR();

unsigned char buf[IR_LIMITS];	// bytes buffer
unsigned char mode;	// 1:NEC, 2:AEHA, 3:SONY
unsigned int bits;	// 32768 bits capable
unsigned char done;


// irin  = GPIO4  = P1_7
// irout = GPIO13 = P1_33
//#define IRIN  RPI_V2_GPIO_P1_07
//#define IROUT RPI_V2_GPIO_P1_33
#define IRIN  7
#define IROUT 23

unsigned char countHigh(){

	unsigned char i=0;

	while( digitalRead(IRIN)==1 );	// wait

	while( digitalRead(IRIN)==0 ){
		++i;
		delayMicroseconds(26);
		delayMicroseconds(26);
		if(i==0) return 0;	// timeout
	}
	// NEC:i=19*8=152, i*2*26.5us=8056us
	// AEHA:i=19*4=76, i*2*26.5us=4028us
	// 1T:i=19*1=19

	return i;

}


unsigned char countLow(){

	unsigned char i=0;

	while( digitalRead(IRIN)==0 );	// wait

	while( digitalRead(IRIN)==1 ){
		++i;
		delayMicroseconds(26);
		if(i==0) return 0;	// timeout
	}
	// NEC:i=19*8=152, i*26.5us=4028us
	// AEHA:i=19*4=76, i*26.5us=2014us
	// 1T:i=19*1=19
	// 3T:i=19*3=57

	return i;

}


void getIR2(){

	unsigned char i;
	unsigned short j;   // capable 32768 bits = 4096 bytes
	unsigned char k;

	bits=0;
	for(j=0;j<IR_LIMITS;j++){  // buffer bytes LIMITS
		for(i=0;i<8;i++){   // 8 bits
			k = countHigh()*2;
			if(mode==3){
				buf[j]>>=1;
				// Threschold = 35, 23 = 1T, 46 = 2T; for SONY
				buf[j]+=((k>30) ? 0x80: 0);
				++bits;
			}
			k = countLow();
			if(k==0){
				buf[j]>>=(8-i);
				return;
			}
			if(mode!=3){
				buf[j]>>=1;
				// Threschold = 38, 19 = 1T, 57 = 3T; for NEC
				// Threschold = 30, 15 = 1T, 45 = 3T; for AEHA
				buf[j]+=((k>30) ? 0x80: 0);
				++bits;
			}
		}
	}

}


void display(unsigned char s)
{
        int i,n;
        char name[][5]={"none","NEC","AEHA","SONY"};

        if(s==2)
        {
                printf("%s",name[mode]);    // 1:NEC, 2:AEHA, 3:SONY
                printf("%02X",bits);    // bits

                // no scroll
                n=(bits+7)/8;    // bits to n bytes
                for(i=0;i<n;i++){
                        printf("%02X",buf[i]);  // data
                }

        }else{

                printf("%s",name[mode]);    // 1:NEC, 2:AEHA, 3:SONY
                printf(" %d",bits);    // bits

                // scroll
                n=(bits+7)/8;    // bits to n bytes
                for(i=0;i<n;i++){
                        printf(" %d",buf[i]);  // data
                }
        }
}


void getIR(){

	unsigned char i;
	
	i = countHigh();    // Start
	mode=0;

	if(40<i){
		if(i<51){
			mode=3; // SONY, 46
		}else{
			if(100<i){
				mode=1; // NEC, 173
			}else{
				mode=2; // AEHA, 54-77
			}
		}
		i = countLow();
		getIR2();
	}
	done=1;
	delay(100);	// to wait this thread until main thread reading done

}


int main(int argc, char *argv[])
{

	wiringPiSetup();

	pinMode(IROUT,OUTPUT);
	pinMode(IRIN,INPUT);
	pullUpDnControl(IRIN,PUD_UP);
	digitalWrite(IROUT,0);

	// to detect falling edge
	wiringPiISR(IRIN,INT_EDGE_FALLING,(void*)getIR);
	done=0;
	waitForInterrupt(IRIN,-1);
	while(done==0);
	display(argc);

}




