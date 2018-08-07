#include <stdio.h>
#include "dzhbitstream.h"
// SIMPLEBITCODE
////////////////////////////////////////////////////////////

typedef struct
{
	unsigned char* m_pData;				
	int m_nBitSize;			
	int m_nCurPos;		
	
	int m_nSavedPos;	
	
	const SIMPLEBITCODE* m_pCodes;
	int	m_nNumCode;
	int	m_nStatus;				
}SIMPLEBITSTREAM;


int IsOriginalData(const SIMPLEBITCODE* pBitCode);
int IsBitPos(const SIMPLEBITCODE* pBitCode);

void InitialBitStream(SIMPLEBITSTREAM* pStream, unsigned char* pData,int nSize);
int GetStatus(SIMPLEBITSTREAM* pStream);
void SetStatus(SIMPLEBITSTREAM* pStream, int nStatus);
const char* GetStatusDesc(int nStatus);
int GetCurPos(SIMPLEBITSTREAM* pStream);

unsigned int Get(SIMPLEBITSTREAM* pStream, int nBit);	
int GetNoMove(SIMPLEBITSTREAM*pStream, int nBit,unsigned int* dw);

int Move(SIMPLEBITSTREAM* pStream, int nBit);
int MoveTo(SIMPLEBITSTREAM* pStream, int nPos);	

void SaveCurrentPos(SIMPLEBITSTREAM* pStream);	
int  RestoreToSavedPos(SIMPLEBITSTREAM* pStream);

void SetBitCode(SIMPLEBITSTREAM* pStream, const SIMPLEBITCODE* pCodes,int nNumCode);

unsigned int DecodeData(SIMPLEBITSTREAM* pStream, unsigned int dwLastData, int bReverse);

const SIMPLEBITCODE* DecodeFindMatch(SIMPLEBITSTREAM* pStream, unsigned int* dw);	

#define SETSIMPLEBITCODE(x,y)	SetBitCode(x, y, sizeof(y)/sizeof(y[0]))
/////////////////////////////////////
int IsOriginalData(const SIMPLEBITCODE* pBitCode)
{
	if (pBitCode->m_cCode == 'D' || pBitCode->m_cCode == 'M')
		return 1;
	else 
		return 0;
}

int IsBitPos(const SIMPLEBITCODE* pBitCode)
{
	if (pBitCode->m_cCode == 'P')
		return 1;
	else
		return 0;
}

// SIMPLEBITSTREAM
////////////////////////////////////////////////////////////////////////////////////////////
static char* StatusDesc[] =
{
	"Run successfully",						// 0		-->SBS_EX_SUCCESS
	"Get Bit Len Error",					// 1		-->SBS_GETBITLEN_ERR
	"Get Pos Out of Range",					// 2		-->SBS_GETPOS_OUTRANGE
	"Move To Pos Out of Range",				// 3		-->SBS_MOVETOPOS_OUTRANGE
	"Decode Cannot Find Match",				// 4		-->SBS_DECODE_NOT_MATCH
	"expand min date error",				// 5		-->SBS_EXPAND_MINDATE
	"expand min date error:no data",		// 6		-->SBS_EXPAND_MINDATE_NODATA
	"expand day date error",				// 7		-->SBS_EXPAND_DAYDATE
	"expand day date error:no data"			// 8		-->SBS_EXPAND_DAYDATE_NODATA
};

int GetStatus(SIMPLEBITSTREAM* pStream)
{
	return pStream->m_nStatus;
}

void SetStatus(SIMPLEBITSTREAM* pStream, int nStatus)
{
	pStream->m_nStatus = nStatus;
}

const char* GetStatusDesc(int nStatus)
{
	char *strTmp;

	switch(nStatus)
	{
	case SBS_GETBITLEN_ERR:
		strTmp = StatusDesc[1];
		break;
	case SBS_GETPOS_OUTRANGE:
		strTmp = StatusDesc[2];
		break;
	case SBS_MOVETOPOS_OUTRANGE:
		strTmp = StatusDesc[3];
		break;
	case SBS_DECODE_NOT_MATCH:
		strTmp = StatusDesc[4];
		break;
	case SBS_EXPAND_MINDATE:
		strTmp = StatusDesc[5];
		break;
	case SBS_EXPAND_MINDATE_NODATA:
		strTmp = StatusDesc[6];
		break;
	case SBS_EXPAND_DAYDATE:
		strTmp = StatusDesc[7];
		break;
	case SBS_EXPAND_DAYDATE_NODATA:
		strTmp = StatusDesc[8];
		break;
	default:
		strTmp = StatusDesc[0];
	}

	return strTmp;
}
//////////////////
void InitialBitStream(SIMPLEBITSTREAM* pStream, unsigned char* pData,int nSize)
{
	pStream->m_pData		= pData;
	pStream->m_nBitSize	= nSize*8;
	pStream->m_nCurPos		= 0;

	pStream->m_pCodes		= NULL;
	pStream->m_nNumCode	= 0;
	pStream->m_nStatus	= SBS_EX_SUCCESS;
}

unsigned int Get(SIMPLEBITSTREAM* pStream, int nBit)
{
	unsigned int dw = 0;	
	int nMove = GetNoMove(pStream, nBit,&dw);
	pStream->m_nCurPos += nMove;

	return dw;
}

int GetNoMove(SIMPLEBITSTREAM* pStream, int nBit,unsigned int* dw)
{
	int nRet = -1;	
	*dw = 0;

	if (pStream->m_nBitSize <= pStream->m_nCurPos )
	{
		// Get Pos Out of Range
		SetStatus(pStream, SBS_GETPOS_OUTRANGE);
		return nRet;
	}

	if (nBit < 0 || nBit > 32) 
	{
		// Bit Len Error
		SetStatus(pStream, SBS_GETBITLEN_ERR);
	}
	else if ( nBit > 0)
	{
		int nGet;
		int nLeft;
		int nPos;
		if(nBit>pStream->m_nBitSize-pStream->m_nCurPos)
			nBit = pStream->m_nBitSize-pStream->m_nCurPos;
		nPos = pStream->m_nCurPos/8;
		if (pStream->m_nCurPos%8)
		{
			*dw = pStream->m_pData[nPos++];
			nGet = 8 - (pStream->m_nCurPos%8);
			*dw >>= 8-nGet;
			nLeft = nBit-nGet;
		}
		else
		{
			nGet = 0;
			nLeft = nBit;
		}
		if (nLeft>0)
		{
			unsigned int nValue;
			do
			{
				nValue = pStream->m_pData[nPos++];
				*dw |= nValue << nGet;
				nGet += 8;
				nLeft -= 8;
			}while(nLeft>0);
		}
		*dw &= 0xFFFFFFFF >> (32-nBit);
		nRet = nBit;
	}
	return nRet;
}

int GetCurPos(SIMPLEBITSTREAM* pStream)
{ 
	int nRet = -1;
	nRet = pStream->m_nCurPos;
	return nRet;
}

int MoveTo(SIMPLEBITSTREAM* pStream, int nPos)
{
	pStream->m_nCurPos = nPos;
	if(pStream->m_nCurPos < 0 || pStream->m_nCurPos > pStream->m_nBitSize)
	{
		// Move To Pos Out of Range
		SetStatus(pStream, SBS_MOVETOPOS_OUTRANGE);
	}
	return pStream->m_nCurPos;
}

int Move(SIMPLEBITSTREAM* pStream, int nBit)
{
	return MoveTo(pStream, pStream->m_nCurPos+nBit);
}	

void SaveCurrentPos(SIMPLEBITSTREAM* pStream)
{
	pStream->m_nSavedPos = pStream->m_nCurPos;
}

int  RestoreToSavedPos(SIMPLEBITSTREAM* pStream)
{
	return MoveTo(pStream, pStream->m_nSavedPos);
}

void SetBitCode(SIMPLEBITSTREAM* pStream, const SIMPLEBITCODE* pCodes,int nNumCode)
{
	pStream->m_pCodes = pCodes;
	pStream->m_nNumCode = nNumCode;
}

const SIMPLEBITCODE* DecodeFindMatch(SIMPLEBITSTREAM* pStream, unsigned int* dw)
{
	const SIMPLEBITCODE* pCode = NULL;
	*dw = 0;

	if(pStream && pStream->m_pCodes)
	{
		int i;
		unsigned int dwNextCode = 0;
		GetNoMove(pStream, 16, &dwNextCode);
		// Check the GetNoMove() status
		if (SBS_EX_SUCCESS != GetStatus(pStream))
			return NULL;

		for(i=0; i < pStream->m_nNumCode; i++)
		{
			const SIMPLEBITCODE* pCur = pStream->m_pCodes + i;
			if(pCur->m_wCodeBits == (dwNextCode & (0xFFFFFFFF>>(32-pCur->m_nCodeLen))))	//ÊâæÂà∞
			{
				pCode = pCur;
				break;
			}
		}

		if(pCode)
		{
			Move(pStream, pCode->m_nCodeLen);
			// Check the Move() status
			if (SBS_EX_SUCCESS != GetStatus(pStream))
				return NULL;

			if(pCode->m_nDataLen)
			{
				*dw = Get(pStream, pCode->m_nDataLen);
				if (SBS_EX_SUCCESS != GetStatus(pStream))
					return NULL;
			}

			switch(pCode->m_cCode)
			{
			case 'B':
			case 'D':
			case 'M':
			case 's':
				break;
			case 'b':
				if(*dw&(1<<(pCode->m_nDataLen-1)))	//Ë¥üÊï∞
					*dw |= (0xFFFFFFFF<<pCode->m_nDataLen);
				break;
			case 'm':
				*dw |= (0xFFFFFFFF<<pCode->m_nDataLen);
				break;
			case 'S':
				*dw <<= (unsigned short)(((pCode->m_dwCodeData) >> 16) & 0xFFFF);
				break;
			case 'E':
				*dw = pCode->m_dwCodeData;
				break;
			case 'Z':
				{
					int nExp = *dw&3;
					*dw >>= 2;
					*dw += pCode->m_dwDataBias;
					for(i=0;i<=nExp;i++)
						*dw *= 10;
				}
				break;
			case 'P':
				*dw = (1 << *dw);
				break;
			default:
				break;
			}
			if(((*dw & 0x80000000) && (pCode->m_cCode=='b')) || pCode->m_cCode=='m')
				*dw -= pCode->m_dwDataBias;
			//else if(!pCode->IsOriginalData() && pCode->m_cCode!='Z' && pCode->m_cCode!='s')
			else if (!IsOriginalData(pCode) && pCode->m_cCode!='Z' && pCode->m_cCode!='s')
				*dw += pCode->m_dwDataBias;
		}
		else
		{
			// Decode Cannot Find Match
			SetStatus(pStream, SBS_DECODE_NOT_MATCH);
			return NULL;
		}
	}
	return pCode;
}


unsigned int DecodeData(SIMPLEBITSTREAM* pStream, unsigned int dwLastData, int bReverse)
{
	unsigned int dw = 0;

	const SIMPLEBITCODE* pCode = DecodeFindMatch(pStream, &dw);
	if(pCode)
	{
		//if(!pCode->IsOriginalData() && dwLastData)
		if (!IsOriginalData(pCode) && dwLastData)
		{
			if(bReverse)
				dw = dwLastData - dw;
			else
				dw += dwLastData;
		}
	}
	return dw;
}

static SIMPLEBITCODE ZSpriceCode[] = 
{
	{0		,	1,	0,'E',		0, 0},			//0		
	{1		,	2,	2,'b',		2, 0},			//01
	{3		,	3,	4,'b',		4, 1},			//011
	{7	    ,	4,	8,'b',		8, 9},			//0111
	{0xF	,	5, 16,'b',	   16,137},			//01111 
	{0x1F	,	5, 32,'D',		0, 0},			//11111 
};

static SIMPLEBITCODE ZSvolumeCode[] = 
{
	{1		,	2,  4,'B',	    4, 0},			//01
	{0		,	1,  8,'B',	    8, 16},			//0	
	{3		,	3, 12,'B',	   12,272},			//011
	{7   	,	4, 16,'B',	   16,4368},		//0111
	{0xF	,	5, 24,'B',	   24,69904},		//01111
	{0x1F	,	5, 32,'D',	    0, 0},			//11111
};

static const MMINUTE constMINData;
static const FUTUREMMINUTE constFutureMINData;

static unsigned int GetZsTime (unsigned short pos, const MARKETTIME* pMarketTime, unsigned short* pTimePos)
{
	unsigned short i;
	unsigned int nRetTime = 0;
	for (i = 0; i < pMarketTime->m_nNum; i++)
	{
		if (pos < pTimePos[i])
		{
			if (i)
			{
				pos -= pTimePos[i-1];
				pos++;
			}
			nRetTime = (pMarketTime->m_TradeTime[i].m_wOpen%100+pos%60)/60;
			nRetTime = (pMarketTime->m_TradeTime[i].m_wOpen/100+nRetTime+pos/60)%24*100+(pMarketTime->m_TradeTime[i].m_wOpen%100+pos%60)%60;

			break;
		}
	}
	return nRetTime;
}

static unsigned int GetZsTime2(unsigned short pos, const TRADETIME* pTradeTime, unsigned short nTimeNum, unsigned short* pTimePos)
{
    unsigned int nRetTime = 0;
    for (unsigned short  i = 0; i < nTimeNum; i++)
    {
        if (pos < pTimePos[i])
        {
            if (i)
            {
                pos -= pTimePos[i-1];
                pos++;
            }
            nRetTime = (pTradeTime[i].m_wOpen%100+pos%60)/60;
            nRetTime = (pTradeTime[i].m_wOpen/100+nRetTime+pos/60)%24*100+(pTradeTime[i].m_wOpen%100+pos%60)%60;
            
            break;
        }
    }
    return nRetTime;
}

unsigned short decompressMinData(const char* body, unsigned short bodySize, char* resultData, unsigned short* resultSize, unsigned short* minTotalNum, MARKETTIME** marketTime)
{
    unsigned short nRet                         = 0;
    unsigned short nSum                         = 0;
    
    if (bodySize > sizeof(JAVA_NEWZSHEADDATA) + sizeof(MINCPSHEAD) + sizeof(MARKETTIME))
    {
        JAVA_NEWZSHEADDATA* pZsHead             = (JAVA_NEWZSHEADDATA*)body;//持仓标记、信息地雷数、五星评级、数据位置、记录数
        MINCPSHEAD* pCpsHead                    = (MINCPSHEAD*)(pZsHead+1);//压缩信息
        MARKETTIME* pMarketTime                 = (MARKETTIME*)(pCpsHead+1);//市场交易时间段
        *marketTime                             = pMarketTime;
        
        char* pData                             = (char*)pZsHead + sizeof(JAVA_NEWZSHEADDATA) + sizeof(MINCPSHEAD) + pCpsHead->m_nExchangeNum;
        int nDataLen                            = bodySize - sizeof(JAVA_NEWZSHEADDATA) - sizeof(MINCPSHEAD) - pCpsHead->m_nExchangeNum;
        int	nCellLen                            = pZsHead->m_nTag ? sizeof(FUTUREMMINUTE) : sizeof(MMINUTE);//每个数据项的大小
        
        if (*resultSize >= sizeof(JAVA_NEWZSHEADDATA) + nCellLen * (pCpsHead->m_nCompressNum + pCpsHead->m_nUnCompressNum))
        {
            unsigned int dwTmpVal;
            unsigned short i;
            SIMPLEBITSTREAM stream;
            unsigned short  pTimePos[8];
            int nStatus                         = 0;
            JAVA_NEWZSHEADDATA* pResZsHead      = (JAVA_NEWZSHEADDATA*)resultData;
            const FUTUREMMINUTE* pOldData       = &constFutureMINData;
            FUTUREMMINUTE* pMinBuf              = (FUTUREMMINUTE*)(pResZsHead+1);
            
            InitialBitStream(&stream, (unsigned char*)pData, nDataLen);
            
            *pResZsHead                         = *pZsHead;
            
            for (i = 0; i < pMarketTime->m_nNum && i < 8; i++)
            {
                if (pMarketTime->m_TradeTime[i].m_wEnd < pMarketTime->m_TradeTime[i].m_wOpen)
                {
                    pTimePos[i]                 = (pMarketTime->m_TradeTime[i].m_wEnd/100+24-pMarketTime->m_TradeTime[i].m_wOpen/100)*60+pMarketTime->m_TradeTime[i].m_wEnd%100-pMarketTime->m_TradeTime[i].m_wOpen%100;
                }
                else
                {
                    pTimePos[i]                 = (pMarketTime->m_TradeTime[i].m_wEnd/100-pMarketTime->m_TradeTime[i].m_wOpen/100)*60+pMarketTime->m_TradeTime[i].m_wEnd%100-pMarketTime->m_TradeTime[i].m_wOpen%100;
                }
                nSum                            += pTimePos[i] / pCpsHead->m_nMinInterval;//计算该时间段具有多少个分钟数据
                if (i)
                {
                    pTimePos[i]                 += pTimePos[i-1];
                }
                else
                {
                    pTimePos[i]++;
                }
            }
            *minTotalNum                        = nSum + 1;//当天完整分时具有的数据个数
            
            for(i=0; i<pCpsHead->m_nCompressNum; i++)
            {
                //时间
                pMinBuf->m_time                 = GetZsTime (i*pCpsHead->m_nMinInterval, pMarketTime, pTimePos);
                
                //最新价
                SETSIMPLEBITCODE(&stream, ZSpriceCode);
                dwTmpVal                        = DecodeData(&stream, pOldData->m_dwPrice, 0);
                if ((nStatus = GetStatus(&stream)))
                {
                    printf("decompress error:%s", GetStatusDesc(nStatus));
                    return 0;
                }
                pMinBuf->m_dwPrice              = dwTmpVal;
                
                //成交量
                SETSIMPLEBITCODE(&stream, ZSvolumeCode);
                dwTmpVal                        = DecodeData(&stream, pOldData->m_dwVolume, 0);
                if ((nStatus = GetStatus(&stream)))
                {
                    printf("decompress error:%s", GetStatusDesc(nStatus));
                    return 0;
                }
                pMinBuf->m_dwVolume             = dwTmpVal;
                
                //均价
                SETSIMPLEBITCODE(&stream, ZSpriceCode);
                dwTmpVal                        = DecodeData(&stream, pOldData->m_dwAmount, 0);
                if ((nStatus = GetStatus(&stream)))
                {
                    printf("decompress error:%s", GetStatusDesc(nStatus));
                    return 0;
                }
                pMinBuf->m_dwAmount             = dwTmpVal;
                
                if(pZsHead->m_nTag)//持仓量
                {
                    dwTmpVal                    = DecodeData(&stream, pOldData->m_dwOpenInterest, 0);
                    if ((nStatus = GetStatus(&stream)))
                    {
                        printf("decompress error:%s", GetStatusDesc(nStatus));
                        return 0;
                    }
                    pMinBuf->m_dwOpenInterest   = dwTmpVal;
                    pOldData                    = pMinBuf++;
                }
                else
                {
                    pOldData                    = pMinBuf;
                    pMinBuf                     = (FUTUREMMINUTE*)((char*)pMinBuf+sizeof(MMINUTE));
                }
                nRet++;
            }
            
            if (pCpsHead->m_nUnCompressNum && (GetCurPos(&stream)+7)/8 + (nCellLen-sizeof(unsigned int))*pCpsHead->m_nUnCompressNum <= nDataLen)
            {
                CPSMIN* pUnData                 = (CPSMIN*)(pData + nDataLen - (nCellLen - sizeof(unsigned int)) * pCpsHead->m_nUnCompressNum);
                for (i = 0; i < pCpsHead->m_nUnCompressNum; i++)
                {
                    pMinBuf->m_time             = GetZsTime((pCpsHead->m_nCompressNum+i) * pCpsHead->m_nMinInterval, pMarketTime, pTimePos);
                    pMinBuf->m_dwPrice          = pUnData->m_dwPrice;
                    pMinBuf->m_dwVolume         = pUnData->m_dwVolume;
                    pMinBuf->m_dwAmount         = pUnData->m_dwAmount;
                    if(pZsHead->m_nTag)
                    {
                        CPSFUTUREMIN* pFutureUnData     = (CPSFUTUREMIN*)pUnData;
                        pMinBuf->m_dwOpenInterest       = pFutureUnData->m_dwOpenInterest;
                        pMinBuf++;
                        pUnData                 = (CPSMIN*)((char*)pFutureUnData + sizeof(CPSFUTUREMIN));
                    }
                    else
                    {
                        pMinBuf                 = (FUTUREMMINUTE*)((char*)pMinBuf + sizeof(MMINUTE));
                        pUnData++;
                    }
                    nRet++;
                }
            }
        }
        *resultSize                             = sizeof(JAVA_NEWZSHEADDATA) + nCellLen * (pCpsHead->m_nCompressNum + pCpsHead->m_nUnCompressNum);
    }
    return nRet;
}

/*
 static SIMPLEBITCODE MinKLDateCode[] = 
 {
 {0		,	1,	0,'X',		0, 0},			//0	
 {1		,	2,  3,'B',		3, 0},			//01 
{3		,	2, 32,'D',		0, 0},			//11
};

static SIMPLEBITCODE DayKLDateCode[] = 
{
{0		,	1,	0,'X',		0, 0},			//0	
{1		,	2,  5,'K',		5, 0},			//01
{3		,	2, 32,'D',		0, 0},			//11
};
*/
static SIMPLEBITCODE KLineOpenpriceCode[] =
{
	{1		,	2,	8,'b',		8,	0},			//01
	{0		,	1, 16,'b',	   16,128},			//0	
	{0x3	,	3, 24,'b',	   24,32896},		//011
	{0x7	,	3, 32,'D',	   0,	0},			//111
};

static SIMPLEBITCODE KLinepriceCode[] =
{
	{1		,	2,	8,'B',		8,	0},			//01
	{0		,	1, 16,'B',	   16,256},			//0	
	{0x3	,	3, 24,'B',	   24,65792},		//011	
	{0x7	,	3, 32,'D',	   0,	0},			//111
};

static SIMPLEBITCODE KLinevolCode[] =
{
	{0x1	,	2, 12,'b',	   12,	0},			// 01
	{0x0	,	1, 16,'b',	   16,2048},		// 0
	{0x3	,	3, 24,'b',	   24,34816},		// 011
	{0x7	,	3, 32,'D',	    0,	0},			// 111
};


static SIMPLEBITCODE KLamountCode[] =	
{
	{0x3	,	3, 12,'b',	   12,	0},			// 011
	{0x1	,	2, 16,'b',	   16,2048},		// 01	
	{0x0	,	1, 24,'b',	   24,34816},		// 0
	{0x7	,	3, 32,'D',	   0,	0},			// 111
};

static const MKDATA constKLineData;
static const FutureMKDATA constFutureKLine;

static unsigned int ExpandMinKLDate(SIMPLEBITSTREAM* stream, const unsigned int lastdate, const unsigned int nCircle)//??
{
	unsigned int     data;
	MinKLTime nNow;
	unsigned int* pIntnNow = (unsigned int*)&nNow;

	*pIntnNow = 0;

	GetNoMove(stream, 16, &data);
	if (SBS_EX_SUCCESS == GetStatus(stream))
	{
		if ((data&0x00000001) == 0)//
		{
			*pIntnNow = lastdate;
			unsigned int minvalue = nNow.m_nMin+nCircle;
			
			if (minvalue >= 60)
			{
				nNow.m_nMin = minvalue-60;
				nNow.m_nHour++;
			}
			else
			{
				nNow.m_nMin = minvalue;
			}
			Move(stream, 1);
		}
		else if ((data&0x00000003) == 3)
		{
			Move(stream, 2);
			data = Get(stream, 32);

			if (SBS_EX_SUCCESS == GetStatus(stream))
				*pIntnNow = data;
		}
		else
		{
			// Expand min date error
			SetStatus(stream, SBS_EXPAND_MINDATE);
		}
	}
	else
	{
		//expand min date error:no data
		SetStatus(stream, SBS_EXPAND_MINDATE_NODATA);
	}

	return *pIntnNow;
}

static unsigned int ExpandDayKLDate(SIMPLEBITSTREAM* stream, const unsigned int lastdate, const unsigned int nCircle)
{
	unsigned int data;
	unsigned int date = 0;

	if (!stream) return 0;		// stream is null pointer

	GetNoMove(stream, 16, &data);
	if (SBS_EX_SUCCESS == GetStatus(stream))
	{
		if ((data&0x00000001) == 0)//Ë∑ü‰∏ä‰∏™Êó•ÊúüÂè™Â∑Æ‰∏Ä‰∏™Âë®Êú?	
		{
			Move(stream, 1);
			date = lastdate+nCircle;

		}
		else if ((data&0x0000003) == 1)//
		{
			Move(stream, 7);
			data >>= 2;
			date = (lastdate/100+1)*100+(data&0x0000001F);
		}
		else if ((data&0x0000003) == 3)//
		{
			Move(stream, 2);
			data = Get(stream, 32);
			if (SBS_EX_SUCCESS == GetStatus(stream))
				date = data;
		}
	}
	else
	{
		// Expand day date error: no data
		SetStatus(stream, SBS_EXPAND_DAYDATE_NODATA);
	}

	return date;
}

unsigned short decompressKlineData(const char* body, unsigned short bodySize, char* resultData, unsigned short* resultSize)
{
    unsigned short nRet = 0;
    if (bodySize > sizeof(char) + sizeof(unsigned short) + sizeof(KLINECPSHEAD))
    {
        unsigned short	nDataLen                = bodySize - sizeof(char) - sizeof(unsigned short);
        unsigned char*	pData                   = (unsigned char*)(body + sizeof(char) + sizeof(unsigned short));
        char tag                                = *body;
        KLINECPSHEAD* pHead                     = (KLINECPSHEAD*)pData;
        FutureMKDATA* pKLineBuf                 = (FutureMKDATA*)(resultData + sizeof(char) + sizeof(unsigned short));
        int	nCellLen                            = tag ? sizeof(FutureMKDATA) : sizeof(MKDATA);
        
        if (sizeof(char) + sizeof(unsigned short) + pHead->m_nNum * nCellLen <= *resultSize)
        {
            unsigned int nCircle                = 0;
            unsigned short  i;
            SIMPLEBITSTREAM stream;
            unsigned int dwTmpVal               = 0;
            int nStatus                         = 0;
            const FutureMKDATA* pOldData        = &constFutureKLine;
            InitialBitStream(&stream, (unsigned char*)(pData + sizeof(KLINECPSHEAD)), nDataLen - sizeof(KLINECPSHEAD));
            switch (pHead->m_nKLType)
            {
                case ktypeMin1:
                    nCircle = 1;
                    break;
                case ktypeMin5:
                    nCircle = 5;
                    break;
                case ktypeMin15:
                    nCircle = 15;
                    break;
                case ktypeMin30:
                    nCircle = 30;
                    break;
                case ktypeMin60:
                    nCircle = 60;
                    break;
                case ktypeDay:
                    nCircle = 1;
                    break;
                case ktypeWeek:
                    nCircle = 7;
                    break;
                case ktypeMonth:
                    nCircle = 100;
                    break;
                default:
                    break;
            }
            for(i = 0; i < pHead->m_nNum; i++)
            {
                //日期
                if (pHead->m_nKLType <= ktypeMin60)
                {
                    dwTmpVal                    = ExpandMinKLDate(&stream, pOldData->m_dwDate, nCircle);
                    if ((nStatus = GetStatus(&stream)))
                    {
                        printf("decompress error:%s", GetStatusDesc(nStatus));
                        return 0;
                    }
                    pKLineBuf->m_dwDate         = dwTmpVal;
                }
                else
                {
                    dwTmpVal                    = ExpandDayKLDate(&stream, pOldData->m_dwDate, nCircle);
                    if ((nStatus = GetStatus(&stream)))
                    {
                        printf("decompress error:%s", GetStatusDesc(nStatus));
                        return 0;
                    }
                    pKLineBuf->m_dwDate = dwTmpVal;
                }
                
                SETSIMPLEBITCODE(&stream, KLineOpenpriceCode);
                dwTmpVal                        = DecodeData(&stream, pOldData->m_dwClose, 0);
                if ((nStatus = GetStatus(&stream)))
                {
                    printf("decompress error:%s", GetStatusDesc(nStatus));
                    return 0;
                }
                pKLineBuf->m_dwOpen             = dwTmpVal;
                
                SETSIMPLEBITCODE(&stream, KLinepriceCode);
                dwTmpVal                        = DecodeData(&stream, pKLineBuf->m_dwOpen, 0);
                if ((nStatus = GetStatus(&stream)))
                {
                    printf("decompress error:%s", GetStatusDesc(nStatus));
                    return 0;
                }
                pKLineBuf->m_dwHigh             = dwTmpVal;
                
                dwTmpVal                        = DecodeData(&stream, pKLineBuf->m_dwOpen, 1);
                if ((nStatus = GetStatus(&stream)))
                {
                    printf("decompress error:%s", GetStatusDesc(nStatus));
                    return 0;
                }
                pKLineBuf->m_dwLow              = dwTmpVal;
                
                dwTmpVal                        = DecodeData(&stream, pKLineBuf->m_dwLow, 0);
                if ((nStatus = GetStatus(&stream)))
                {
                    printf("decompress error:%s", GetStatusDesc(nStatus));
                    return 0;
                }
                pKLineBuf->m_dwClose            = dwTmpVal;
                
                SETSIMPLEBITCODE(&stream, KLinevolCode);
                dwTmpVal                        = DecodeData(&stream, pOldData->m_dwVolume, 0);
                if ((nStatus = GetStatus(&stream)))
                {
                    printf("decompress error:%s", GetStatusDesc(nStatus));
                    return 0;
                }
                pKLineBuf->m_dwVolume           = dwTmpVal;
                
                SETSIMPLEBITCODE(&stream, KLamountCode);
                dwTmpVal                        = DecodeData(&stream, pOldData->m_dwAmount, 0);
                if ((nStatus = GetStatus(&stream)))
                {
                    printf("decompress error:%s", GetStatusDesc(nStatus));
                    return 0;
                }
                pKLineBuf->m_dwAmount           = dwTmpVal;
                
                if(tag)
                {
                    dwTmpVal                    = DecodeData(&stream, pOldData->m_dwOpenInterest, 0);
                    if ((nStatus = GetStatus(&stream)))
                    {
                        printf("decompress error:%s", GetStatusDesc(nStatus));
                        return nRet;
                    }
                    pKLineBuf->m_dwOpenInterest = dwTmpVal;
                    pOldData                    = pKLineBuf++;
                }
                else
                {
                    pOldData                    = pKLineBuf;
                    pKLineBuf                   = (FutureMKDATA*)((char*)pKLineBuf + sizeof(MKDATA));
                }
                
                nRet++;
            }
            
            *resultData                         = tag;
            *((unsigned short*)(resultData + 1))= nRet;
        }
        
        *resultSize                             = sizeof(char) + sizeof(unsigned short) + pHead->m_nNum * nCellLen;
    }
    return nRet;
}

unsigned short decompressKlineHisMinData(const char* body, unsigned short bodySize, char* resultData, unsigned short* resultSize, unsigned short* minTotalNum, MARKETTIME** marketTime)
{
    unsigned short nRet                         = 0;
    if (bodySize > sizeof(HISMISRES))
    {
        unsigned short i;
        int nDataLen;
        char* pResBuf;
        char* pData;
        char* pTimeNum                          = NULL;
        unsigned short nSum                     = 0;
        TRADETIME* pTime                        = NULL;
        HISMISRES* pHisRes                      = (HISMISRES*)body;
        int	nCellLen                            = sizeof(int);
        unsigned short pTimePos[8];
        
        if(pHisRes->m_nMask & 0x01)
        {
            nCellLen                            += sizeof(int);
        }
        if(pHisRes->m_nMask & 0x02)
        {
            nCellLen                            += sizeof(int);
        }
        if(pHisRes->m_nMask & 0x04)
        {
            nCellLen                            += sizeof(int);
        }
        if(pHisRes->m_nMask & 0x08)
        {
            nCellLen                            += sizeof(int);
        }
        
        if(pHisRes->m_nMask & 0x01)
        {
            pTimeNum                            = (char*)(pHisRes + 1);
            pTime                               = (TRADETIME*)(pTimeNum + 1);
            pData                               = (char*)(pTime + *pTimeNum);
            nDataLen                            = bodySize - sizeof(HISMISRES) - sizeof(char) - sizeof(TRADETIME) * (*pTimeNum);
            for (i = 0; i < *pTimeNum && i < 8; i++)
            {
                if (pTime[i].m_wEnd < pTime[i].m_wOpen)
                {
                    pTimePos[i] = (pTime[i].m_wEnd/100+24-pTime[i].m_wOpen/100)*60+pTime[i].m_wEnd%100-pTime[i].m_wOpen%100;
                }
                else
                {
                    pTimePos[i] = (pTime[i].m_wEnd/100-pTime[i].m_wOpen/100)*60+pTime[i].m_wEnd%100-pTime[i].m_wOpen%100;
                }
                nSum                            += pTimePos[i] / pHisRes->m_nInterval;
                if (i)
                {
                    pTimePos[i]                 += pTimePos[i-1];
                }
                else
                {
                    pTimePos[i]++;
                }
            }
        }
        else
        {
            pData                               = (char*)(pHisRes + 1);
            nDataLen                            = bodySize - sizeof(HISMISRES);
        }
        *minTotalNum                            = nSum + 1;
        if(nDataLen > 0 && *resultSize >= sizeof(HISMISRES) + nCellLen * pHisRes->m_nNum)
        {
            HISMISRES* pHisResultRes            = (HISMISRES*)resultData;
            *pHisResultRes                      = *pHisRes;
            pResBuf                             = (char*)(pHisResultRes + 1);
            SIMPLEBITSTREAM stream;
            int nStatus                         = 0;
            InitialBitStream(&stream, (unsigned char*)pData, nDataLen);
            
            int nPrice                          = 0;
            int nVol                            = 0;
            int nAvg                            = 0;
            int nOpenInterest                   = 0;
            
            for(i = 0; i < pHisRes->m_nNum; i++)
            {
                //时间
                if(pHisRes->m_nMask & 0x01)
                {
                    *(int*)pResBuf              = GetZsTime2((i+pHisRes->m_nPos)*pHisRes->m_nInterval, pTime, *pTimeNum, pTimePos);
                    pResBuf                     += sizeof(int);
                }
                
                //最新价
                SETSIMPLEBITCODE(&stream, ZSpriceCode);
                *(int*)pResBuf                  = DecodeData(&stream, nPrice, 0);
                if ((nStatus = GetStatus(&stream)))
                {
                    printf("decompress error:%s", GetStatusDesc(nStatus));
                    return 0;
                }
                nPrice                          = *(int*)pResBuf;
                pResBuf                         += sizeof(int);
                
                //成交量
                if(pHisRes->m_nMask & 0x02)
                {
                    SETSIMPLEBITCODE(&stream, ZSvolumeCode);
                    *(int*)pResBuf              = DecodeData(&stream, nVol, 0);
                    if ((nStatus = GetStatus(&stream)))
                    {
                        printf("decompress error:%s", GetStatusDesc(nStatus));
                        return 0;
                    }
                    nVol                        = *(int*)pResBuf;
                    pResBuf                     += sizeof(int);
                }
                
                //均价
                if(pHisRes->m_nMask & 0x04)
                {
                    SETSIMPLEBITCODE(&stream, ZSpriceCode);
                    *(int*)pResBuf              = DecodeData(&stream, nAvg, 0);
                    if ((nStatus = GetStatus(&stream)))
                    {
                        printf("decompress error:%s", GetStatusDesc(nStatus));
                        return 0;
                    }
                    nAvg                        = *(int*)pResBuf;
                    pResBuf                     += sizeof(int);
                }
                
                //持仓量
                if(pHisRes->m_nMask & 0x08)
                {
                    SETSIMPLEBITCODE(&stream, ZSpriceCode);
                    *(int*)pResBuf              = DecodeData(&stream, nOpenInterest, 0);
                    if ((nStatus = GetStatus(&stream)))
                    {
                        printf("decompress error:%s", GetStatusDesc(nStatus));
                        return 0;
                    }
                    pResBuf                     += sizeof(int);
                }
                nRet++;
            }
        }
        *resultSize                             = sizeof(HISMISRES) + nCellLen * pHisRes->m_nNum;
    }
    return nRet;
}
