import QtQuick 2.9
import MuseScore 3.0
import QtQuick.Dialogs 1.0
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.1
import FileIO 3.0
import QtQuick.Controls.Styles 1.4
import Qt.labs.settings 1.0

MuseScore {
      menuPath: "Plugins.AsistenteComposicion"
      description: "Asistente de composición musical con inteligencia artificial, de generos nacionales(Bolivia)"
      
      version: "3.0"
      pluginType: "dialog"
      requiresScore: false
      id:window
      width: 400; height: 200;
      
      property int ultimoCursorTick : 0
      property int saltoCursorTick : 0
      property int saltoBarras : 0
      property bool cargando: false
      property string urlBase : "http://127.0.0.1:8000/"
      FileIO {
        id: exampleFile
        source: "C:/Users/Fernando/Documents/MuseScore3/Plugins/vocabulario2022.json"
      }
      FileIO {
        id: fileVocaInverso
        source: "C:/Users/Fernando/Documents/MuseScore3/Plugins/vocabulario_inverso_2022.json"
      }
      FileIO {
        id: fileMIDI
        source: "C:/Users/Fernando/Documents/MuseScore3/Plugins/vocabularioMIDI.json"
      }
      function extract()
      {     var test2 = exampleFile.read();
            var diccionario= JSON.parse(test2);
            var measure = curScore.firstMeasure;
            var acumulador =[]
            var conLlave=0  
            var ultimoTick=0
            var idUltimaNota=0
            while (measure ) {
                  var segment = measure.firstSegment;

                  while(segment){
                        // console.log("################ "+ segment.tick);
                        for (var t = 0; t < curScore.ntracks; ++t) {
                              var el = segment.elementAt(t);
                              if (el){
                                    if(el._name()=="KeySig" || conLlave==1){
                                          // console.log("Tonalidad "+ curScore.keysig);
                                          conLlave= conLlave+1
                                          acumulador.push(diccionario[curScore.keysig.toString()])
                                    }
                                     if(el.name=="Clef" && conLlave==0){                                          
                                          // console.log('Clave : '+el.name);
                                          acumulador.push(diccionario["clave_G_2"])
                                          conLlave= conLlave+1
                                    }
                                    if(el.name=="TimeSig"){
                                          // console.log('compas : '+el.timesig.str);
                                          acumulador.push(diccionario[el.timesig.str])
                                    }
                                    if (el.type == Element.CHORD){
                                          for (var n in el.notes) {
                                                var nu=el.duration.numerator;
                                                var de=el.duration.denominator;
                                                var dur=(nu/de)*4;
                                                // console.log("datos " + el.notes[n].pitch +" duracion "+dur+ " numerador : "+nu + " denominador :"+de);
                                               
                                                var notaSt = el.notes[n].pitch.toString();
                                                acumulador.push(diccionario[notaSt])
                                                if(dur==1 || dur==2 || dur==3 || dur==4){
                                                      var duraFlo =dur.toFixed(1)
                                                      acumulador.push(diccionario[duraFlo.toString()])
                                                }else{
                                                      acumulador.push(diccionario[dur.toString()])
                                                }
                                                
                                                if(el.notes[n].tieForward != null && el.notes[n].tieBack != null ){
                                                      acumulador.push(diccionario["liga_continue"])
                                                }else{
                                                      if(el.notes[n].tieForward != null){
                                                            // console.log("/////////");
                                                            // console.log(el.notes[n].tieForward)
                                                      acumulador.push(diccionario["liga_start"])
                                                      }
                                                      if(el.notes[n].tieBack != null){
                                                            // console.log("/////////");
                                                            // console.log(el.notes[n].tieBack)
                                                            acumulador.push(diccionario["liga_stop"])
                                                      }
                                                }
                                                
                                                for (var notEl in el.notes[n].elements) {
                                                      // console.log(el.notes[n].elements[notEl].type + "daaa" + el.notes[n].elements[notEl].name+"#########");
                                                }
                                          }
                                          ultimoTick= segment.tick;
                                          idUltimaNota=acumulador.length;
                                    }
                                    if(el.type ==Element.REST){
                                          var nu=el.duration.numerator;
                                          var de=el.duration.denominator;
                                          var dur=(nu/de)*4;
                                          if(dur==1 || dur==2 || dur==3 || dur==4){
                                                var duraFlo =dur.toFixed(1)
                                                acumulador.push(diccionario["silencio"])
                                                acumulador.push(diccionario[duraFlo.toString()])
                        
                                          }else{
                                                acumulador.push(diccionario["silencio"])
                                                acumulador.push(diccionario[dur.toString()])
                                          }
                                          // console.log(el.name+" valor "+dur);
                                    }
                                   
                                    // console.log("numero "+el.type+"nombre "+el.name);
                                   
                                    
                                     if (el._name() == "BarLine"){
                                          // console.log(el.subtypeName() +"#########");
                                          if(el.subtypeName() == "start-repeat"){
                                          // console.log("start-repeat");
                                          acumulador.push(diccionario["b_repeticion_start"])
                                          }
                                          if(el.subtypeName() == "end-repeat"){
                                                // console.log("end-repeat");
                                                acumulador.push(diccionario["b_repeticion_end"])
                                          }
                                          if(el.subtypeName() == "end") {
                                                // console.log("end-start-repeat barra");
                                                acumulador.push(diccionario["b_final"])
                                          }
                                          if(el.subtypeName() == "double") {
                                                // console.log("end-start-repeat barra");
                                                acumulador.push(diccionario["b_regular"])
                                          }
                                     }
                                    
                                    // console.log(" sub type: "+ el._name()+" s "+el.subtypeName());
                                    
                              }
                        }
                        
                        segment = segment.nextInMeasure;
                        
                  }
                  measure = measure.nextMeasure;
            }
            
            
            ultimoCursorTick=ultimoTick
            
            // console.log(ultimoTick);
            // console.log(idUltimaNota);
            // console.log(acumulador);
            idUltimaNota=idUltimaNota+saltoCursorTick*2+saltoBarras
            var acumCortado=acumulador.slice(0,idUltimaNota)
            // console.log(acumCortado);
            
            return acumCortado;
            
      
      }
      function ultimaPosicionFun()
      {     
            var measure = curScore.firstMeasure;
            var ultimoTick=0
           
            while (measure ) {
                  var segment = measure.firstSegment;

                  while(segment){
                        // console.log("################ "+ segment.tick);
                        for (var t = 0; t < curScore.ntracks; ++t) {
                              var el = segment.elementAt(t);
                              if (el){
                                    
                                    if (el.type == Element.CHORD){
                                          
                                          ultimoTick= segment.tick;
                                          
                                    }
                              }
                        }
                        
                        segment = segment.nextInMeasure;
                        
                  }
                  measure = measure.nextMeasure;
            }
            
            
            ultimoCursorTick=ultimoTick
            
      
      }
      function asignarDuracion(duration,cursor){
            switch(duration){
                  case "0.125":     cursor.setDuration(1,32);
                              break;
                  case "0.25":     cursor.setDuration(1,16);
                              break;
                  case "0.375":     cursor.setDuration(3,32);
                              break;
                  case "0.5":     cursor.setDuration(1,8);
                              break;
                  case "0.75":     cursor.setDuration(3,16);
                              break;
                  case "1.0":     cursor.setDuration(1,4);
                              break;
                  case "1.5":     cursor.setDuration(3,8);
                              break;
                  case "2.0":     cursor.setDuration(1,2);
                              break;
                  case "3.0":     cursor.setDuration(3,4);
                              break;
                  case "4.0":     cursor.setDuration(1,1);
                              break;
            }
      }
      
      function agregarBarras(tipoBarra,cursor){
            var measure = cursor.measure;
            if(tipoBarra == "b_repeticion_start"||tipoBarra == "b_regular"){                       
                  var segment = measure.prevMeasure.lastSegment      
                  console.log("entro barra start");
                  console.log(segment);
            }else{
                  var segment = measure.lastSegment;
            }
            
            var bar = segment.elementAt(0);
            curScore.startCmd();
            if (bar.type == Element.BAR_LINE) {
                  if(tipoBarra == "b_repeticion_start"){                       
                        bar.barlineType = 4;                      
                  }
                  if(tipoBarra == "b_repeticion_end"){
                        bar.barlineType = 8;
                  }
                  if(tipoBarra == "b_final"){
                        bar.barlineType = 32;
                  }
                  if(tipoBarra == "b_regular"){
                        bar.barlineType = 2;
                  }
                  saltoBarras=saltoBarras+1;
            }
            curScore.endCmd();
      }
      function agregarNotas(listaVal,verNotas){
            var test2 = fileVocaInverso.read();
            var dicInverso= JSON.parse(test2);
            console.log("################################");
            console.log(ultimoCursorTick);
            console.log(listaVal);
            curScore.startCmd();
            var cursor = curScore.newCursor();
            cursor.rewindToTick(ultimoCursorTick);
            
            if(listaVal.length == 1){
                  var b = listaVal[0]
                  if(b==27||b==28 || b==29||b==30){
                        agregarBarras(dicInverso[listaVal[0].toString()],cursor)
                  }
                  console.log(dicInverso[listaVal[0].toString()])
            }
            for(var i=0;i<=saltoCursorTick;i++){
                  cursor.next();
            }
            
            if(listaVal.length ==2 ){
                  console.log("################################---Notas");
                  console.log(dicInverso[listaVal[1].toString()]);
                  
                  
                  asignarDuracion(dicInverso[listaVal[1].toString()],cursor)
                  if(listaVal[0]==26){
                        cursor.addRest();
                        textNotaGen.text = "Silencio";
                        saltoCursorTick=saltoCursorTick+1
                  }else{
                        var notaMidi =parseInt(dicInverso[listaVal[0].toString()])
                        cursor.addNote(notaMidi);
                        if(verNotas){
                              cambiarNotaGenerada(notaMidi);
                        }else{
                              ultimaPosicionFun()
                        }
                        
                        saltoCursorTick=0
                  }
                  if(saltoBarras>0){
                        saltoBarras=0
                  }
                  console.log("################################---Notas");
            }
            if(listaVal.length ==3){
                  console.log("################################---Notas");
                  console.log(dicInverso[listaVal[1].toString()]);
                  console.log(parseInt(dicInverso[listaVal[0].toString()]));
                  console.log(dicInverso[listaVal[2]]);
                  console.log("################################---Notas");
                  asignarDuracion(dicInverso[listaVal[1].toString()],cursor)
                  if(listaVal[0]==26){
                        cursor.addRest();
                        textNotaGen.text = "Silencio";
                        saltoCursorTick=saltoCursorTick+1
                  }else{
                        var notaMidi =parseInt(dicInverso[listaVal[0].toString()])
                        cursor.addNote(notaMidi);
                        if(verNotas){
                              cambiarNotaGenerada(notaMidi);
                        }else{
                              ultimaPosicionFun()
                        }
                        saltoCursorTick=0
                  }
                                    
                  if(dicInverso[listaVal[2]]=="liga_continue" || dicInverso[listaVal[2]]=="liga_stop"){
                        curScore.startCmd();
                        var cursor = curScore.newCursor();
                        cursor.rewindToTick(ultimoCursorTick);
                        var notaActual=cursor.element.notes[0].pitch
                        cursor.prev()
                        var valSeleccion = curScore.selection.select(cursor.element.notes[0],false)
                        console.log("#########################");
                        
                        var notaAnterior=cursor.element.notes[0].pitch
                        console.log("notaAnterior "+ notaAnterior.toString());
                        console.log(" actualizar :"+ notaActual.toString());
                        if(valSeleccion ){
                              if(notaAnterior==notaActual){
                                    cmd("tie");
                              }else{
                                    cmd("add-slur");
                              }
                        }                      
                       
                        cursor.rewindToTick(ultimoCursorTick);
                  }
                  if(saltoBarras>0){
                        saltoBarras=0
                  }
                  
            }
         
            cargando=false
            curScore.endCmd();
      }
      function cambiarNotaGenerada(notaPitch){
            var test2 = fileMIDI.read();
            var diccionario= JSON.parse(test2);
            var notaTexto=diccionario[notaPitch.toString()];
            textNotaGen.text = notaTexto;
      }
      function genListaCompleta(listaVal){
            
            var notasEscogidas=[]
            
            for (var i = 0; i <listaVal.length; i++){
                  if(notasEscogidas.length==0){
                        //selecciona notas
                        if(listaVal[i]>=58 ||listaVal[i]==26){
                              notasEscogidas.push(listaVal[i] );
                        }else{
                              //selecciona barras
                              if(listaVal[i]>=27 && listaVal[i]<=30){
                                    notasEscogidas.push(listaVal[i])
                                    
                                    agregarNotas(notasEscogidas,false)
                                    notasEscogidas=[]
                              }
                        }
                  }else{
                        if(notasEscogidas.length==1){
                              //selecciona duraciones
                              if(listaVal[i]>=3 && listaVal[i]<=18){
                                    notasEscogidas.push(listaVal[i]);
                              }
                              if(listaVal[i+1]>=19 && listaVal[i+1]<=21){
                                    notasEscogidas.push(listaVal[i+1]);
                                    agregarNotas(notasEscogidas,false)
                                    notasEscogidas=[]
                              }else{
                                    
                                    agregarNotas(notasEscogidas,false)
                                    notasEscogidas=[]
                              }
                        }
                  }
                  
                 
                  
            }
            textNotaGen.text = "Partitura Generada";


      }
      ColumnLayout {
        id: panMain

        anchors.fill: parent
        spacing: 1
        anchors.topMargin: 10
        anchors.rightMargin: 10
        anchors.leftMargin: 10
        anchors.bottomMargin: 5

       
      RowLayout {
            Text {
                  id: textAviso
                  //anchors.centerIn: parent
                  x: 20
                  y: 20
                  text: qsTr("Nota Generada: ")
                  font.bold: true
                  fontSizeMode: Text.Fit
                  font.pixelSize: 15 
            }
            Text {
                  id: textNotaGen
                  //anchors.centerIn: parent
                  x: 20
                  y: 50
                  text: qsTr("Notas generadas.")
                  font.bold: true
                  fontSizeMode: Text.Fit
                  font.pixelSize: 25 
                  
            }
      }
      RowLayout {
            spacing:20
            anchors.horizontalCenter: parent.horizontalCenter
            Button {
                  id : buttonUnaNota
                  text: qsTr("Siguiente")
                  
                  enabled: !cargando
                  highlighted:true
                  onClicked: {
                  cargando=true
                  var partitura = extract()
                  console.log(partitura);
                  var content={
                        contenido: partitura
                  }
                  var request = new XMLHttpRequest()
                  request.onreadystatechange = function() {
                        if (request.readyState == XMLHttpRequest.DONE) {
                              var response = request.responseText
                              console.log("responseText : " + response)
                              var part =JSON.parse(request.response)
                              console.log("responseText : ")
                              console.log(part);
                              agregarNotas(part,true);
                              // Qt.quit()
                              }
                        }
                  request.open("POST", urlBase+"generador")
                  request.setRequestHeader("Content-Type", "application/json")
                  var jsonString=JSON.stringify(content)
                  request.send(jsonString)
                  }
                  contentItem: Text {
                        text: buttonUnaNota.text
                        font: buttonUnaNota.font     
                                      
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                  }
                  background: Rectangle {
                        implicitWidth: 100
                        implicitHeight: 40
                        opacity: enabled ? 1 : 0.3
                        border.color: buttonUnaNota.down ? "#17a81a" : "#061407"
                        border.width: 1
                        radius: 10
                  }
            }
            Button {
                  id : buttonLista
                  text: qsTr("Generador")
                  
                  enabled: !cargando
                  highlighted:true
                  onClicked: {
                  cargando=true
                  var partitura = extract()
                  console.log(partitura);
                  var content={
                        contenido: partitura
                  }
                  var request = new XMLHttpRequest()
                  request.onreadystatechange = function() {
                        if (request.readyState == XMLHttpRequest.DONE) {
                              // var response = request.responseText
                              // console.log("responseText : " + response)
                              var part =JSON.parse(request.response)
                              console.log("responseText : ")
                              console.log(part);
                              genListaCompleta(part)
                              cargando=false
                              // Qt.quit()
                              }
                        }
                  request.open("POST", urlBase+"genlist")
                  request.setRequestHeader("Content-Type", "application/json")
                  var jsonString=JSON.stringify(content)
                  request.send(jsonString)
                  }
                  contentItem: Text {
                        text: buttonLista.text
                        font: buttonLista.font     
                                      
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                  }
                  background: Rectangle {
                        implicitWidth: 100
                        implicitHeight: 40
                        opacity: enabled ? 1 : 0.3
                        border.color: buttonLista.down ? "#17a81a" : "#061407"
                        border.width: 1
                        radius: 10
                  }
            }
            Button {
                  id : buttonPrueba
                  text: qsTr("Salir")
                  
                  onClicked: {
                        Qt.quit()
                  }
                  contentItem: Text {
                        text: buttonPrueba.text
                        font: buttonPrueba.font     
                                      
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                  }
                  background: Rectangle {
                        implicitWidth: 100
                        implicitHeight: 40
                        opacity: enabled ? 1 : 0.3
                        border.color: buttonPrueba.down ? "#17a81a" : "#061407"
                        border.width: 1
                        radius: 10
                  }
            }
      }
      }
      BusyIndicator {
        id: busyIndicator
        x: Math.round((parent.width - width) / 2)
        y: Math.round((parent.height - height) / 2)
        width: 60
        height: 60
        running: cargando
        visible: cargando
      }
      onRun: {
            
           
            // console.log(salida["<start>"]);
            
            // extract()
            // Qt.quit()
            
      }
      
}


