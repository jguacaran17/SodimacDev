/*********************************************************************************
Project      : Sodimac Salesforce Service Cloud
Created By   : Deloitte
Created Date : 05/05/2020
Description  : JS That validates the different types of documents for the different countries
History                                                            
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                      ACRONYM
Abdón Tejos Oliva        ATO
Eilhert Andrade A.       EAA
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      ATO      05/05/2020    initial version 
1.1      EAA      05/10/2020    Update tipoDocumento CO
********************************************************************************/

  /* Document Validation */
  window.jsValidateDocument = function (tipoDocumento, input) {
    if (tipoDocumento == "RUT") {
      return jsValidateRUT(input);
    } else if (tipoDocumento == "RUC") {
      return jsValidateRUC(input);
    } else if (tipoDocumento == "RFC") {
      return jsValidateRFC(input);
    } else if (tipoDocumento == "DNI") {
      return jsValidateDNI(input);
    } else if (tipoDocumento == "CC" || tipoDocumento == "CE" || tipoDocumento == "TI") {
      return jsValidateTipoDocCO(input);
    } else if (tipoDocumento == "PAS" ) {
      return jsValidatePAS(input);
    } else if (tipoDocumento == "NIT" ) {
      return jsValidateNIT(input);
    } else {
        console.log('Validación de documento aun no definida. Tipo de documento no validado: ' + tipoDocumento);
        return jsValidateAnyId(input, tipoDocumento);
    }
  }

  /* Validation of other types of documents */
  window.jsValidateAnyId = function (input, tipoDocumento) {
      var lnt = input.get("v.value");
      console.log('lnt.length: ' + lnt.length)
      if ((tipoDocumento == 'Pasaporte' && lnt.length > 12) ||
         (tipoDocumento == 'Documento identidad país de residencia' && (lnt.length > 15 || lnt.length < 3))) {
          input.setCustomValidity(tipoDocumento + " Inválido");
          input.reportValidity();
          return false;      
      } else {
          input.setCustomValidity("");
          input.reportValidity();
          return true;
      }
  }

  /* RUT Validation */
  window.jsValidateRUT = function (rut) {
    // Despejar Puntos
    var valor = rut.get("v.value").replace(".", "");
    // Despejar Guión
    valor = valor.replace("-", "");

    // Aislar Cuerpo y Dígito Verificador
    var cuerpo = valor.slice(0, -1),
      dv = valor.slice(-1).toUpperCase();
    console.log("3: " + cuerpo + " y " + dv);

    // RUT formatting
    rut.set("v.value", cuerpo + "-" + dv);

    // if don't meet the minimum ej. (n.nnn.nnn)
    if (cuerpo.length < 7) {
      rut.setCustomValidity("RUT Incompleto");
      rut.reportValidity();
      return false;
    }

    // Check Digit calc
    var suma = 0,
      multiplo = 2;

    // For each digit of the Body
    for (var i = 1; i <= cuerpo.length; i++) {
      // Obtener su Producto con el Múltiplo Correspondiente
      var index = multiplo * valor.charAt(cuerpo.length - i);

      // Add to the General Accountant
      suma = suma + index;

      // Consolidate Multiplo within range [2,7]
      if (multiplo < 7) {
        multiplo = multiplo + 1;
      } else {
        multiplo = 2;
      }
    }

    // Calculate Check Digit based on Module 11
    var dvEsperado = 11 - (suma % 11);

    // Spetial case (0 y K)
    dv = dv == "K" ? 10 : dv;
    dv = dv == 0 ? 11 : dv;

    // Validate that the Body matches with the Check Digit
    if (dvEsperado != dv) {
      rut.setCustomValidity("RUT Inválido");
      rut.reportValidity();
      return false;
    }

    // If every thing OK, delete error (Is Valid!)
    rut.setCustomValidity("");
    rut.reportValidity();

    return true;
  }

  /* RUC Validation */
  window.jsValidateRUC = function (input) {
  	var ruc = input
      .get("v.value")
      .replace(".", "")
      .replace("-", "");
    
    const regex = /^(10|20|15|16|17){1}\d{9}$/;
    var isValid = ruc.match(regex);
    input.set("v.value", ruc);
    
    if (!isValid) {
      input.setCustomValidity("RUC Inválido");
      input.reportValidity();
      return false;
    } else {
      input.setCustomValidity("");
      input.reportValidity();
      return true;
    }
  }

  /* RFC Validation */
  window.jsValidateRFC = function (input) {
    var rfc = input
      .get("v.value")
      .replace(".", "")
      .replace("-", "");
    const regex = /^([A-ZÑ&]{3,4}) ?(?:- ?)?(\d{2}(?:0[1-9]|1[0-2])(?:0[1-9]|[12]\d|3[01])) ?(?:- ?)?([A-Z\d]{2})([A\d])$/;
    var isValid = rfc.match(regex);

    input.set("v.value", rfc);

    if (!isValid) {
      input.setCustomValidity("RFC Inválido");
      input.reportValidity();
      return false;
    } else {
      input.setCustomValidity("");
      input.reportValidity();
      return true;
    }
  }

  /* DNI validation */
  window.jsValidateDNI = function (input) {
    var dni = input
      .get("v.value")
      .replace(".", "")
      .replace("-", "");
    const regex = /^\d{8}$/;
    var isValid = dni.match(regex);

    input.set("v.value", dni);

    if (!isValid) {
      input.setCustomValidity("DNI Inválido");
      input.reportValidity();
      return false;
    } else {
      input.setCustomValidity("");
      input.reportValidity();
      return true;
    }
  }

  /* Colombia's document validation */
  window.jsValidateTipoDocCO = function (input) {
    var docCo = input
      .get("v.value")
      .replace(".", "")
      .replace("-", "");
    const regex = /^\d{1,25}$/;
    var isValid = docCo.match(regex);

    input.set("v.value", docCo);

    if (!isValid) {
      input.setCustomValidity("Tipo de Documento Inválido");
      input.reportValidity();
      return false;
    } else {
      input.setCustomValidity("");
      input.reportValidity();
      return true;
    }
  }

    /* Colombia's passport validation */
    window.jsValidatePAS = function (input) {
      var pas = input
        .get("v.value")
        .replace(".", "")
        .replace("-", "");
      const regex = /^[a-zA-Z0-9]{0,25}$/;
      var isValid = pas.match(regex);
  
      input.set("v.value", pas);
  
      if (!isValid) {
        input.setCustomValidity("Pasaporte Inválido");
        input.reportValidity();
        return false;
      } else {
        input.setCustomValidity("");
        input.reportValidity();
        return true;
      }
    }

    /* Colombia's NIT validation */
    window.jsValidateNIT = function (input) {
      var nit = input
        .get("v.value")
        .replace(".", "");
      const regex = /^[0-9]{1,23}-[0-9]{1}$/;
      var isValid = nit.match(regex);
  
      input.set("v.value", nit);
  
      if (!isValid) {
        input.setCustomValidity("NIT Inválido");
        input.reportValidity();
        return false;
      } else {
        input.setCustomValidity("");
        input.reportValidity();
        return true;
      }
    }