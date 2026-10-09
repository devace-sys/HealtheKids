using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Net;
using System.Web.Configuration;
using System.Collections.Specialized;
using System.Xml.Linq;
using System.IO;
using System.Web.Script.Serialization;

namespace Geo.USPS
{
	/***************************************************************************
	 * OAuthTokenResponse */
	/**
	 * Response object for OAuth token request
	 * Maps to the JSON response from USPS OAuth2 token endpoint
	 ***************************************************************************/

	public class OAuthTokenResponse
	{
		public string access_token { get; set; }
		public string token_type { get; set; }
		public long issued_at { get; set; }           // Unix timestamp in milliseconds
		public int expires_in { get; set; }           // Seconds until expiration
		public string status { get; set; }
		public string scope { get; set; }
		public string issuer { get; set; }
		public string client_id { get; set; }
		public string application_name { get; set; }
		public string api_products { get; set; }
		public string public_key { get; set; }

		public OAuthTokenResponse()
		{
			this.access_token = String.Empty;
			this.token_type = String.Empty;
			this.issued_at = 0;
			this.expires_in = 0;
			this.status = String.Empty;
			this.scope = String.Empty;
			this.issuer = String.Empty;
			this.client_id = String.Empty;
			this.application_name = String.Empty;
			this.api_products = String.Empty;
			this.public_key = String.Empty;
		}

		/***************************************************************************
		 * GetIssuedAtDateTime */
		/**
		 * Converts the Unix timestamp (milliseconds) to a DateTime object
		 ***************************************************************************/
		public DateTime GetIssuedAtDateTime()
		{
			// Convert milliseconds since Unix epoch to DateTime
			DateTimeOffset dateTimeOffset = DateTimeOffset.FromUnixTimeMilliseconds(this.issued_at);
			return dateTimeOffset.DateTime;
		}

		/***************************************************************************
		 * GetExpirationDateTime */
		/**
		 * Calculates when the token will expire
		 ***************************************************************************/
		public DateTime GetExpirationDateTime()
		{
			return GetIssuedAtDateTime().AddSeconds(this.expires_in);
		}

		/***************************************************************************
		 * IsExpired */
		/**
		 * Checks if the token has expired
		 ***************************************************************************/
		public bool IsExpired()
		{
			return DateTime.Now >= GetExpirationDateTime();
		}
	}

	/***************************************************************************
	 * AddressStandardizationResponse */
	/**
	 * Response object for address standardization request
	 ***************************************************************************/

	public class AddressStandardizationResponse
	{
		public string streetAddress { get; set; }
		public string streetAddressAbbreviation { get; set; }
		public string secondaryAddress { get; set; }
		public string cityAbbreviation { get; set; }
		public string city { get; set; }
		public string state { get; set; }
		public string ZIPCode { get; set; }
		public string ZIPPlus4 { get; set; }
		public string urbanization { get; set; }
		public AddressStandardizationResponse()
		{
			this.streetAddress = String.Empty;
			this.streetAddressAbbreviation = String.Empty;
			this.secondaryAddress = String.Empty;
			this.cityAbbreviation = String.Empty;
			this.city = String.Empty;
			this.state = String.Empty;
			this.ZIPCode = String.Empty;
			this.ZIPPlus4 = String.Empty;
			this.urbanization = String.Empty;
		}
	}

	/***************************************************************************
	 * AddressStandardization */
	/**
	 * USPS Address Standardization API v3 with OAuth2 authentication
	 * 
	 * This implementation uses a two-step process:
	 * 1. Request OAuth2 access token using client credentials
	 * 2. Use the access token to request address standardization
	 * 
	 ***************************************************************************/

	public class AddressStandardization
	{

		/***************************************************************************
		 * RequestOAuthToken */
		/**
		 * Requests an OAuth2 access token using client credentials grant type
		 * 
		 * @param oauthUrl       OAuth2 token endpoint URL
		 * @param clientId       Consumer Key (client_id)
		 * @param clientSecret   Consumer Secret (client_secret)
		 * @param errorMessage   Output: Error message if request fails
		 * @param tokenResponse  Output: OAuth token response object
		 * @return              True if successful, false otherwise
		 ***************************************************************************/

		public static bool RequestOAuthToken(string oauthUrl,
											  string clientId,
											  string clientSecret,
											  out string errorMessage,
											  out OAuthTokenResponse tokenResponse)
		{
			errorMessage = String.Empty;
			tokenResponse = new OAuthTokenResponse();

			try
			{
				/*----------------------------
				 * Validate inputs
				 *----------------------------*/

				if (String.IsNullOrEmpty(oauthUrl))
				{
					errorMessage = "OAuth URL is required";
					return false;
				}

				if (String.IsNullOrEmpty(clientId))
				{
					errorMessage = "Client ID is required";
					return false;
				}

				if (String.IsNullOrEmpty(clientSecret))
				{
					errorMessage = "Client Secret is required";
					return false;
				}

				/*----------------------------
				 * Build request body
				 *----------------------------*/

				string postData = String.Format("grant_type=client_credentials&client_id={0}&client_secret={1}&scope=addresses",
												System.Web.HttpUtility.UrlEncode(clientId),
												System.Web.HttpUtility.UrlEncode(clientSecret));

				byte[] data = Encoding.UTF8.GetBytes(postData);

				/*----------------------------
				 * Create and configure request
				 *----------------------------*/

				using (WebClient wc = new WebClient())
				{
					wc.Headers.Add("Content-Type", "application/x-www-form-urlencoded");
					wc.Headers.Add("Accept", "application/json");
					wc.Encoding = System.Text.Encoding.UTF8;
					wc.UseDefaultCredentials = false;
					wc.CachePolicy = new System.Net.Cache.RequestCachePolicy(System.Net.Cache.RequestCacheLevel.NoCacheNoStore);

					ServicePointManager.ServerCertificateValidationCallback = new System.Net.Security.RemoteCertificateValidationCallback(delegate { return true; });

					/*----------------------------
					 * Send request
					 *----------------------------*/

					string response = wc.UploadString(oauthUrl, "POST", postData);

					/*----------------------------
					 * Parse response
					 *----------------------------*/

					if (String.IsNullOrWhiteSpace(response))
					{
						errorMessage = "Empty response from OAuth server";
						return false;
					}

					JavaScriptSerializer serializer = new JavaScriptSerializer();
					tokenResponse = serializer.Deserialize<OAuthTokenResponse>(response);

					if (String.IsNullOrEmpty(tokenResponse.access_token))
					{
						errorMessage = "No access token returned";
						return false;
					}

				}
			}
			catch (WebException wex)
			{
				if (wex.Response != null)
				{
					using (StreamReader reader = new StreamReader(wex.Response.GetResponseStream()))
					{
						errorMessage = "OAuth error: " + reader.ReadToEnd();
					}
				}
				else
				{
					errorMessage = "OAuth error: " + wex.Message;
				}
				return false;
			}
			catch (Exception e)
			{
				errorMessage = "OAuth error: " + e.Message;
				return false;
			}

			return true;
		}

		/***************************************************************************
		 * BuildQueryString */
		/**
		 * Builds query string for address standardization request
		 * 
		 * @param addressIn     Input address object
		 * @return             Query string with parameters
		 ***************************************************************************/

		private static string BuildQueryString(Address addressIn)
		{
			List<string> parameters = new List<string>();

			// streetAddress (required)
			if (!String.IsNullOrEmpty(addressIn.Street1))
			{
				parameters.Add(String.Format("streetAddress={0}", System.Web.HttpUtility.UrlEncode(addressIn.Street1)));
			}

			// secondaryAddress (optional)
			if (!String.IsNullOrEmpty(addressIn.Street2))
			{
				parameters.Add(String.Format("secondaryAddress={0}", System.Web.HttpUtility.UrlEncode(addressIn.Street2)));
			}

			// city (optional)
			if (!String.IsNullOrEmpty(addressIn.City))
			{
				parameters.Add(String.Format("city={0}", System.Web.HttpUtility.UrlEncode(addressIn.City)));
			}

			// state (required)
			if (!String.IsNullOrEmpty(addressIn.State))
			{
				parameters.Add(String.Format("state={0}", System.Web.HttpUtility.UrlEncode(addressIn.State)));
			}

			// ZIPCode (optional)
			if (!String.IsNullOrEmpty(addressIn.Zip5))
			{
				parameters.Add(String.Format("ZIPCode={0}", System.Web.HttpUtility.UrlEncode(addressIn.Zip5)));
			}

			// ZIPPlus4 (optional)
			if (!String.IsNullOrEmpty(addressIn.Zip4))
			{
				parameters.Add(String.Format("ZIPPlus4={0}", System.Web.HttpUtility.UrlEncode(addressIn.Zip4)));
			}

			return "?" + String.Join("&", parameters.ToArray());
		}

		/***************************************************************************
		 * RequestAddressStandardization */
		/**
		 * Requests address standardization using JWT token
		 * 
		 * @param apiUrl         Address standardization API URL
		 * @param accessToken    JWT access token from OAuth
		 * @param addressIn      Input address object
		 * @param errorMessage   Output: Error message if request fails
		 * @param responseData   Output: Raw JSON response
		 * @return              True if successful, false otherwise
		 ***************************************************************************/

		private static bool RequestAddressStandardization( string     apiUrl,
														   string     accessToken,
														   Address    addressIn,
														   out string errorMessage,
														   out string responseData)
		{
			errorMessage = String.Empty;
			responseData = String.Empty;

			try
			{
				/*----------------------------
				 * Build request URL
				 *----------------------------*/

				string queryString = BuildQueryString(addressIn);
				string requestUrl = apiUrl + queryString;

                /*----------------------------
				 * Create and configure request
				 *----------------------------*/

                using (WebClient wc = new WebClient())
                {
                    wc.Headers.Add("Authorization", "Bearer " + accessToken);
                    wc.Headers.Add("Content-Type", "application/json");
                    wc.Encoding = System.Text.Encoding.UTF8;
                    wc.UseDefaultCredentials = false;
                    wc.CachePolicy = new System.Net.Cache.RequestCachePolicy(System.Net.Cache.RequestCacheLevel.NoCacheNoStore);

                    ServicePointManager.ServerCertificateValidationCallback = new System.Net.Security.RemoteCertificateValidationCallback(delegate { return true; });

                    /*----------------------------
					 * Send request
					 *----------------------------*/

                    responseData = wc.DownloadString(requestUrl);

                    /*----------------------------
					 * Validate response
					 *----------------------------*/

                    if (String.IsNullOrWhiteSpace(responseData))
                    {
                        errorMessage = "Empty or no response";
                        return false;
                    }

                    responseData = responseData.Trim();

                    // Check if response appears to be valid JSON
                    if (!((responseData.StartsWith("{") && responseData.EndsWith("}")) ||
                          (responseData.StartsWith("[") && responseData.EndsWith("]"))))
                    {
                        errorMessage = "Invalid response data, expected JSON";
                        return false;
                    }

					/*----------------------------
					 * Extract "address" node from response
					 * The full response contains: firm, address, additionalInfo, corrections, matches, warnings
					 * We only need the "address" node
					 *----------------------------*/

					try
					{
						JavaScriptSerializer serializer = new JavaScriptSerializer();
						Dictionary<string, object> fullResponse = serializer.Deserialize<Dictionary<string, object>>(responseData);

						if (fullResponse != null && fullResponse.ContainsKey("address"))
						{
							// Extract just the "address" node and serialize it back to JSON
							object addressNode = fullResponse["address"];
							responseData = serializer.Serialize(addressNode);
						}
						else
						{
							errorMessage = "Response does not contain 'address' node";
							return false;
						}
					}
					catch (Exception ex)
					{
						errorMessage = "Failed to extract address from response: " + ex.Message;
						return false;
					}
				}
            }
            catch (WebException wex)
			{
				if (wex.Response != null)
				{
					using (StreamReader reader = new StreamReader(wex.Response.GetResponseStream()))
					{
						errorMessage = "API error: " + reader.ReadToEnd();
					}
				}
				else
				{
					errorMessage = "API error: " + wex.Message;
				}
				return false;
			}
			catch (Exception e)
			{
				errorMessage = "API error: " + e.Message;
				return false;
			}

			return true;
		}

		/***************************************************************************
		 * ParseResponseData */
		/**
		 * Parse JSON response data from address standardization API
		 * 
		 * @param responseData  Raw JSON response
		 * @param errorMessage  Output: Error message if parsing fails
		 * @param addressOut    Output: Standardized address
		 * @return             True if successful, false otherwise
		 ***************************************************************************/

		private static bool ParseResponseData(string responseData,
											   out string errorMessage,
											   out Address addressOut)
		{
			errorMessage = String.Empty;
			addressOut = new Address();

			try
			{
				JavaScriptSerializer serializer = new JavaScriptSerializer();
				AddressStandardizationResponse response = serializer.Deserialize<AddressStandardizationResponse>(responseData);

				// Map response to Address object
				addressOut.Street1 = response.streetAddress ?? String.Empty;      // Primary street address
				addressOut.Street2 = response.secondaryAddress ?? String.Empty;   // Secondary address (apt, suite, etc.)
				addressOut.City = response.city ?? String.Empty;
				addressOut.State = response.state ?? String.Empty;
				addressOut.Zip5 = response.ZIPCode ?? String.Empty;
				addressOut.Zip4 = response.ZIPPlus4 ?? String.Empty;

				// Apply title case formatting to city
				if (!String.IsNullOrEmpty(addressOut.City))
				{
					addressOut.City = Geo.Common.ToTitleCase(addressOut.City);
				}

				// Ensure state is uppercase
				if (!String.IsNullOrEmpty(addressOut.State))
				{
					addressOut.State = addressOut.State.ToUpper().Trim();
				}
			}
			catch (Exception e)
			{
				errorMessage = "Parse error: " + e.Message;
				return false;
			}

			return true;
		}

		/***************************************************************************
		 * CheckForRequiredFields */
		/**
		 * Verify that fields required by USPS API v3 are provided
		 * 
		 * @param addressIn     Input address
		 * @param errorMessage  Output: Error message if validation fails
		 * @return             True if valid, false otherwise
		 ***************************************************************************/

		private static bool CheckForRequiredFields(Address addressIn, out string errorMessage)
		{
			errorMessage = String.Empty;

			// streetAddress is required
			if (String.IsNullOrEmpty(addressIn.Street1))
			{
				errorMessage = "Street address is required";
				return false;
			}

			// state is required
			if (String.IsNullOrEmpty(addressIn.State))
			{
				errorMessage = "State is required";
				return false;
			}

			return true;
		}

		/***************************************************************************
		 * RequestAddressValidation */
		/**
		 * Request address validation from USPS using OAuth2 and v3 API
		 * 
		 * This is the main public method that orchestrates the entire process:
		 * 1. Request OAuth token
		 * 2. Use token to request address standardization
		 * 3. Parse and return the result
		 * 
		 * @param oauthUrl           OAuth2 token endpoint URL
		 * @param clientId           Consumer Key (client_id)
		 * @param clientSecret       Consumer Secret (client_secret)
		 * @param apiUrl             Address standardization API URL
		 * @param addressIn          Input address to standardize
		 * @param requestTimeStamp   Output: Request timestamp
		 * @param responseTimeStamp  Output: Response timestamp
		 * @param errorMessage       Output: Error message if request fails
		 * @param addressOut         Output: Standardized address
		 * @return                  True if successful, false otherwise
		 ***************************************************************************/

		public static bool RequestAddressValidation( string oauthUrl,
													 string clientId,
													 string clientSecret,
													 string apiUrl,
													 Address addressIn,
													 out DateTime requestTimeStamp,
													 out DateTime responseTimeStamp,
													 out string   errorMessage,
													 out Address  addressOut)
		{
			var now = DateTime.Now;
			requestTimeStamp  = now;
			responseTimeStamp = now;
			errorMessage = String.Empty;
			addressOut   = new Address();

			try
			{
				/*----------------------------
				 * Validate configuration
				 *----------------------------*/

				if (String.IsNullOrEmpty(oauthUrl))
				{
					errorMessage = "OAuth URL is required";
					return false;
				}

				if (String.IsNullOrEmpty(clientId))
				{
					errorMessage = "Client ID is required";
					return false;
				}

				if (String.IsNullOrEmpty(clientSecret))
				{
					errorMessage = "Client Secret is required";
					return false;
				}

				if (String.IsNullOrEmpty(apiUrl))
				{
					errorMessage = "API URL is required";
					return false;
				}

				/*----------------------------
				 * Check required fields
				 *----------------------------*/

				if (!CheckForRequiredFields(addressIn, out errorMessage))
				{
					return false;
				}

				/*----------------------------
				 * Step 1: Request OAuth token
				 *----------------------------*/

				OAuthTokenResponse tokenResponse;
				if (!RequestOAuthToken(oauthUrl, clientId, clientSecret, out errorMessage, out tokenResponse))
				{
					return false;
				}

				/*----------------------------
				 * Step 2: Request address standardization
				 *----------------------------*/

				string responseData;
				if (!RequestAddressStandardization(apiUrl, tokenResponse.access_token, addressIn, out errorMessage, out responseData))
				{
					return false;
				}

				/*----------------------------
				 * Step 3: Parse response
				 *----------------------------*/

				if (!ParseResponseData(responseData, out errorMessage, out addressOut))
				{
					return false;
				}
			}
			catch (Exception e)
			{
				errorMessage = e.Message;
				return false;
			}
			finally
			{
				responseTimeStamp = DateTime.Now;
			}

			return true;
		}
	}
}
