using System;
using System.Security.Cryptography;

namespace MBA
  {
  /*****************************************************************************
  * This class generates random passwords, which do not include ambiguous
  * characters, such as I, l, and 1. The generated password will be made of
  * 7-bit ASCII symbols. Every four characters will include one lower case
  * character, one upper case character, and one number in a random order.
  * <p>
  * This code was created from RandomPassword by obviex.
  * This code itself comes from the CSMCommon library
  *****************************************************************************/
  public class PasswordMaker
    {
    /***************************************************************************
    * Constants
    ***************************************************************************/
    /** Default minimum password length. */ protected static int    LEN_MIN    = 8;
    /** Default maximum password length. */ protected static int    LEN_MAX    = 10;
    /** Lowercase characters. */            protected static string CHR_LOWER  = "abcdefgijkmnopqrstwxyz";
    /** Uppercase characters. */            protected static string CHR_UPPER  = "ABCDEFGHJKLMNPQRSTWXYZ";
    /** Numeric characters. */              protected static string CHR_NUMBER = "23456789";

    /***************************************************************************
    * makePassword */
    /**
    * Makes a password with random length.  Default minimum/maximum lengths will
    * be used.
    *
    * @return  New Password
    */
    public static string makePassword() { return makePassword(LEN_MIN, LEN_MAX); }
    
    /**
    * Makes a password of a given length.
    *
    * @param  len  Password Length
    * @return      New Password
    */
    public static string makePassword(int length) { return makePassword(length, length); }

    /** 
    * Makes a random length password.
    *
    * @param  min  Minimum Length
    * @param  max  Maximum Length
    * @return      New Password
    ***************************************************************************/
    public static string makePassword(int minLength, int   maxLength)
      {
      /*--------------------------------------------*/
      /* Make sure that input parameters are valid. */
      /*--------------------------------------------*/
      if (minLength <= 0 || maxLength <= 0 || minLength > maxLength)
        return null;
      
      /*-------------------------------------------*/
      /* Create a local array containing supported */
      /* password characters grouped by types.     */
      /*-------------------------------------------*/
      char[][] charGroups = new char[][] 
        {
        CHR_LOWER. ToCharArray(),
        CHR_UPPER. ToCharArray(),
        CHR_NUMBER.ToCharArray()
        };
      
      /*--------------------------------------------*/
      /* Use this array to track the number of      */
      /* unused characters in each character group. */
      /*--------------------------------------------*/
      int[] charsLeftInGroup = new int[charGroups.Length];
      
      /*-------------------------------------------------------*/
      /* Initially, all characters in each group are not used. */
      /*-------------------------------------------------------*/
      for (int i=0; i<charsLeftInGroup.Length; i++)
        charsLeftInGroup[i] = charGroups[i].Length;
      
      /*-----------------------------------*/
      /* Use this array to track (iterate  */
      /* through) unused character groups. */
      /*-----------------------------------*/
      int[] leftGroupsOrder = new int[charGroups.Length];
      
      /*-----------------------------------------------*/
      /* Initially, all character groups are not used. */
      /*-----------------------------------------------*/
      for (int i=0; i<leftGroupsOrder.Length; i++)
        leftGroupsOrder[i] = i;
      
      /*-----------------------------------------------------*/
      /* Because we cannot use the default randomizer, which */
      /* is based on the current time (it will produce the   */
      /* same "random" number within a second), we will use  */
      /* a random number generator to seed the randomizer.   */
      /*-----------------------------------------------------*/
      
      /*------------------------------------------------*/
      /* Use a 4-byte array to fill it with random      */
      /* bytes and convert it then to an integer value. */
      /*------------------------------------------------*/
      byte[] randomBytes = new byte[4];
      
      /*------------------------------*/
      /* Generate 4 random bytes. */
      /*------------------------------*/
      RNGCryptoServiceProvider rng = new RNGCryptoServiceProvider();
      rng.GetBytes(randomBytes);
      
      /*----------------------------------------------*/
      /* Convert 4 bytes into a 32-bit integer value. */
      /*----------------------------------------------*/
      int seed = (randomBytes[0] & 0x7f) << 24 |
                  randomBytes[1]         << 16 |
                  randomBytes[2]         <<  8 |
                  randomBytes[3];
      
      /*----------------------------------*/
      /* Now, this is real randomization. */
      /*----------------------------------*/
      Random  random  = new Random(seed);
      
      /*-------------------------------------------*/
      /* This array will hold password characters. */
      /*-------------------------------------------*/
      char[] password = null;
      
      /*-----------------------------------------------*/
      /* Allocate appropriate memory for the password. */
      /*-----------------------------------------------*/
      if (minLength < maxLength)
        password = new char[random.Next(minLength, maxLength+1)];
      else
        password = new char[minLength];
      
      /*------------------------------------------------------*/
      /* Index of the next character to be added to password. */
      /*------------------------------------------------------*/
      int nextCharIdx;
      
      /*----------------------------------------------------*/
      /* Index of the next character group to be processed. */
      /*----------------------------------------------------*/
      int nextGroupIdx;
      
      /*-------------------------------------------------------------------*/
      /* Index which will be used to track not processed character groups. */
      /*-------------------------------------------------------------------*/
      int nextLeftGroupsOrderIdx;
      
      /*-------------------------------------------------------*/
      /* Index of the last non-processed character in a group. */
      /*-------------------------------------------------------*/
      int lastCharIdx;
      
      /*----------------------------------------*/
      /* Index of the last non-processed group. */
      /*----------------------------------------*/
      int lastLeftGroupsOrderIdx = leftGroupsOrder.Length - 1;
      
      /*---------------------------------------------*/
      /* Generate password characters one at a time. */
      /*---------------------------------------------*/
      for (int i=0; i<password.Length; i++)
        {
        /*---------------------------------------------------------------*/
        /* If only one character group remained unprocessed, process it; */
        /* otherwise, pick a random character group from the unprocessed */
        /* group list. To allow a special character to appear in the     */
        /* first position, increment the second parameter of the Next    */
        /* function call by one, i.e. lastLeftGroupsOrderIdx + 1.        */
        /*---------------------------------------------------------------*/
        if (lastLeftGroupsOrderIdx == 0)
          nextLeftGroupsOrderIdx = 0;
        else
            nextLeftGroupsOrderIdx = random.Next(0, 
          lastLeftGroupsOrderIdx);
        
        /*----------------------------------------------*/
        /* Get the actual index of the character group, */
        /* from which we will pick the next character.  */
        /*----------------------------------------------*/
        nextGroupIdx = leftGroupsOrder[nextLeftGroupsOrderIdx];
        
        /*-----------------------------------------------------------------*/
        /* Get the index of the last unprocessed characters in this group. */
        /*-----------------------------------------------------------------*/
        lastCharIdx = charsLeftInGroup[nextGroupIdx] - 1;
        
        /*----------------------------------------------------------------*/
        /* If only one unprocessed character is left, pick it; otherwise, */
        /* get a random character from the unused character list.         */
        /*----------------------------------------------------------------*/
        if (lastCharIdx == 0)
          nextCharIdx = 0;
        else
          nextCharIdx = random.Next(0, lastCharIdx+1);
        
        /*-------------------------------------*/
        /* Add this character to the password. */
        /*-------------------------------------*/
        password[i] = charGroups[nextGroupIdx][nextCharIdx];
        
        /*---------------------------------------------------------------*/
        /* If we processed the last character in this group, start over. */
        /*---------------------------------------------------------------*/
        if (lastCharIdx == 0)
            charsLeftInGroup[nextGroupIdx] = charGroups[nextGroupIdx].Length;

        /*---------------------------------------------*/
        /* There are more unprocessed characters left. */
        /*---------------------------------------------*/
        else
          {
          /*------------------------------------------------*/
          /* Swap processed character with the last         */
          /* unprocessed character so that we don't pick it */
          /* until we process all characters in this group. */
          /*------------------------------------------------*/
          if (lastCharIdx != nextCharIdx)
            {
            char temp = charGroups[nextGroupIdx][lastCharIdx];
            charGroups[nextGroupIdx][lastCharIdx] = 
            charGroups[nextGroupIdx][nextCharIdx];
            charGroups[nextGroupIdx][nextCharIdx] = temp;
            }

          /*---------------------------------------------------------------*/
          /* Decrement the number of unprocessed characters in this group. */
          /*---------------------------------------------------------------*/
          charsLeftInGroup[nextGroupIdx]--;
          }
        
        /*-------------------------------------------------*/
        /* If we processed the last group, start all over. */
        /*-------------------------------------------------*/
        if (lastLeftGroupsOrderIdx == 0)
          lastLeftGroupsOrderIdx = leftGroupsOrder.Length - 1;

        /*-----------------------------------------*/
        /* There are more unprocessed groups left. */
        /*-----------------------------------------*/
        else
          {
          /*-------------------------------------------------------*/
          /* Swap processed group with the last unprocessed group  */
          /* so that we don't pick it until we process all groups. */
          /*-------------------------------------------------------*/
          if (lastLeftGroupsOrderIdx != nextLeftGroupsOrderIdx)
            {
            int temp = leftGroupsOrder[lastLeftGroupsOrderIdx];
            leftGroupsOrder[lastLeftGroupsOrderIdx] = 
            leftGroupsOrder[nextLeftGroupsOrderIdx];
            leftGroupsOrder[nextLeftGroupsOrderIdx] = temp;
            }

          /*---------------------------------------------*/
          /* Decrement the number of unprocessed groups. */
          /*---------------------------------------------*/
          lastLeftGroupsOrderIdx--;
          }
        }
      
      /*------------------------------------------------------------------*/
      /* Convert password characters into a string and return the result. */
      /*------------------------------------------------------------------*/
      return new string(password);
      }

    /*****************************************************************************
    * Test Main
    *****************************************************************************/
    [STAThread]
    static void Main(string[] args)
      {
      for (int i=0; i<100; i++)
        Console.WriteLine(PasswordMaker.makePassword(8, 10));
      }
    }
  }