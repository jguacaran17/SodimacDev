/*
Created By: David Palma (FTC)
Date: 18/02/2021
Class Name: SOD_XS_CaseCreationService
Comments: Class created for APEX Rest Case Creation Service (Response Class)
*/

public class SOD_XS_CaseCreationResponseWrapper {
	public String caseNumber;
	public String caseId;
	public String errorCode;
	public String errorMessage;

	public SOD_XS_CaseCreationResponseWrapper(String caseNumber, String caseId, String errorCode, String errorMessage){
		this.caseNumber = caseNumber;
		this.caseId = caseId;
		this.errorCode = errorCode;
		this.errorMessage = errorMessage;
	}
}