using System;

namespace Geo.USPS
{

	/***************************************************************************
   * Address */
	/**
	 *
	 ***************************************************************************/

	public class Address
	{

		public Address()
		{
			this.Street1 = String.Empty;
			this.Street2 = String.Empty;
			this.City = String.Empty;
			this.State = String.Empty;
			this.Zip5 = String.Empty;
			this.Zip4 = String.Empty;
		}

		public Address(
			  String street1
			, String street2
			, String city
			, String state
			, String zip5
			, String zip4)
		{
			this.Street1 = street1;
			this.Street2 = street2;
			this.City = city;
			this.State = state;
			this.Zip5 = zip5;
			this.Zip4 = zip4;
		}

		public override string ToString()
		{
			return string.Format("[Address: Street1={0}, Street2={1}, City={2}, State={3}, Zip5={4}, Zip4={5}]", Street1, Street2, City, State, Zip5, Zip4);
		}

		public string Street1 { get; set; }
		public string Street2 { get; set; }
		public string City { get; set; }
		public string State { get; set; }
		public string Zip5 { get; set; }
		public string Zip4 { get; set; }

	}
}

