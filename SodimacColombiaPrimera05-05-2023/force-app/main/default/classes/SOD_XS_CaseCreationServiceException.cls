/*
****************************************************************************
Created By: David Palma (FTC)
Date: 23/02/2021
Class Name: SOD_XS_CaseCreationServiceException
Comments: Class created for APEX Rest Case Creation Service for Exceptions
****************************************************************************
*/

public class SOD_XS_CaseCreationServiceException extends Exception{
	public string errorCode;
	public string errorMessage;

	public SOD_XS_CaseCreationServiceException(string errorCode, string errorMessage){
		this.errorCode = errorCode;
		this.errorMessage = errorMessage;
	}
}