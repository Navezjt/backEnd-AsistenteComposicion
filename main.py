from fastapi import FastAPI
from pydantic import BaseModel
import onnxruntime as ort 
import numpy as np
from scipy.special import softmax
from fastapi.encoders import jsonable_encoder
from typing import List
duration=[3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,]
ligas=[19,20,21]
unSoloValor=[0,1,2,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,]
brakets=[22,23,24,25,27]
ort_session = ort.InferenceSession('models/Epoch200.onnx')
app =FastAPI()

class Partitura(BaseModel):
    contenido: List[int]=[]

@app.get('/')
def mensaje():
    return {
        "datos": "Hola mundo",
    }


@app.get('/saludo')
def mensaje():
    return {
        "datos": "Estoy saludando",
    }
    
@app.post('/generador',response_model=List[int])
def generador(partitura:Partitura)->list:
    parte=partitura.contenido
    nuevaList=[]
    listaBrakts=[]
    print(parte)
    controlBraket=True
    while controlBraket:
        if len(listaBrakts)>0:
            parte=partitura.contenido
            parte=np.concatenate((parte,listaBrakts))
            listaBrakts=[]
            
        for i in range(3):
            part=np.array(parte)
            part=np.expand_dims(part,axis=(0))
            part=np.int64(part)
            salida= ort_session.run(["output"],{"input":part})[0]
            salida=salida[:,-1,:]/1
            probs =softmax(salida,axis=-1)
            n=np.argmax(probs,axis=-1)
            print(n[0])
            if len(nuevaList)==2 and n[0] in ligas:
                nuevaList.append(n[0])
                controlBraket=False
            if n[0]in unSoloValor:
                nuevaList.append(n[0])
                controlBraket=False
                break
            if n[0] in duration or n[0] in range(58,145+1)or n[0]== 26 :
                if len(nuevaList)!=2: 
                    nuevaList.append(n[0])
                    controlBraket=False
            if n[0] in ligas and len(nuevaList)!=2:
                parte=np.concatenate((parte,[n[0]]))
            if n[0] in brakets:
                listaBrakts.append(n[0])
                break
            if len(nuevaList)==3:
                controlBraket=False
            parte=np.concatenate((parte,nuevaList))
        
    print(nuevaList)  
    return nuevaList


@app.post('/genlist',response_model=List[int])
def generador(partitura:Partitura)->list:
    parte=partitura.contenido
    nuevalista=[]
    if len(parte)>350:
        parte=parte[-350:]
    # print(parte)
    for i in range(300):
        part=np.array(parte)
        part=np.expand_dims(part,axis=(0))
        part=np.int64(part)
        salida= ort_session.run(["output"],{"input":part})[0]
        salida=salida[:,-1,:]/1.0
        probs =softmax(salida,axis=-1)
        n=np.argmax(probs,axis=-1)
        # print(n[0])
        if n[0]==28:
            nuevalista.append(n[0])
            break
        else:
            nuevalista.append(n[0])
            parte.append(n[0])
        
    # print(parte)  
    return nuevalista
   