using System;
using System.Text;
using System.Security.Cryptography;

namespace MBA
  {
  /*****************************************************************************
  * Encrypter Class */
  /**
  * This class generates and compares hashes using MD5, SHA1, SHA256, SHA384,
  * and SHA512 hashing algorithms. Before computing a hash, it appends a
  * randomly generated salt to the plain text, and stores this salt appended to
  * the result. To verify another plain text value against the given hash, this
  * class will retrieve the salt value from the hash string and use it when
  * computing a new hash of the plain text. Appending a salt value to the hash
  * may not be the most efficient approach, so when using hashes in a real-life
  * application, you may choose to store them separately. You may also opt to
  * keep results as byte arrays instead of converting them into base64-encoded
  * strings.
  *
  * This code was created from SimpleHash by obviex.
  * This code itself comes from the CSMCommon library.
  *****************************************************************************/
  public class Encrypter
    {
    /***************************************************************************
    * Constants
    ***************************************************************************/
    /** MD5 algorithm. */    public static string MD5    = "MD5";
    /** SHA1 algorithm. */   public static string SHA1   = "SHA1";
    /** SHA256 algorithm. */ public static string SHA256 = "SHA256";
    /** SHA384 algorithm. */ public static string SHA384 = "SHA384";
    /** SHA512 algorithm. */ public static string SHA512 = "SHA512";

    /***************************************************************************
    * Sugar
    ***************************************************************************/
    /* Encrypt with MD5 algorithm. */    public static string encryptMD5   (string text)              { return encrypt(text, MD5,    null); }  
    /* Encrypt with SHA1 algorithm. */   public static string encryptSHA1  (string text)              { return encrypt(text, SHA1,   null); }  
    /* Encrypt with SHA256 algorithm. */ public static string encryptSHA256(string text)              { return encrypt(text, SHA256, null); }  
    /* Encrypt with SHA384 algorithm. */ public static string encryptSHA384(string text)              { return encrypt(text, SHA384, null); }  
    /* Encrypt with SHA512 algorithm. */ public static string encryptSHA512(string text)              { return encrypt(text, SHA512, null); }  
    /* Verify with MD5 encryption. */    public static bool   verifyMD5    (string text, string hash) { return verify (text, MD5,    hash); }
    /* Verify with SHA1 encryption. */   public static bool   verifySHA1   (string text, string hash) { return verify (text, SHA1,   hash); }
    /* Verify with SHA256 encryption. */ public static bool   verifySHA256 (string text, string hash) { return verify (text, SHA256, hash); }
    /* Verify with SHA384 encryption. */ public static bool   verifySHA384 (string text, string hash) { return verify (text, SHA384, hash); }
    /* Verify with SHA512 encryption. */ public static bool   verifySHA512 (string text, string hash) { return verify (text, SHA512, hash); }

    /***************************************************************************
    * encrypt */
    /**
    * Encrypts a plain text value and returns a base64-encoded result. Before
    * the hash is computed, a random salt is generated and appended to the plain
    * text. This salt is stored at the end of the hash value, so it can be used
    * later for hash verification.
    *
    * @param  text  Text to be Encrypted
    * @param  algo  Hashing Algorithm
    */
    public static string encrypt(string text, string algo) { return encrypt(text, algo, null); }
    
    /**
    * Encrypts a plain text value with the provided salt and returns a
    * base64-encoded result.
    *
    * @param  text  Text to be Encrypted
    * @param  algo  Hashing Algorithm
    * @param  salt  Salt bytes, null=Generate Random Salt
    * @return       Base64-Encoded String
    ***************************************************************************/
    protected static string encrypt(string text, string algo, byte[] salt)
      {
      /*------------------------------------------------*/
      /* Generate an 8 byte salt with cryptographically */
      /* strong byte values if not specified.           */
      /*------------------------------------------------*/
      if (salt == null)
        {
        salt = new byte[8];
        RNGCryptoServiceProvider rng = new RNGCryptoServiceProvider();
        rng.GetNonZeroBytes(salt);
        }

      /*-----------------------------------------------------------------*/
      /* Create byte array to encrypt from plain text and appended salt. */
      /*-----------------------------------------------------------------*/
      byte[] textBytes   = Encoding.UTF8.GetBytes(text);
      byte[] textAndSalt = new byte[textBytes.Length + salt.Length];

      for (int i=0; i < textBytes.Length; i++)
        textAndSalt[i] = textBytes[i];

      for (int i=0, p=textBytes.Length; i < salt.Length; i++, p++)
        textAndSalt[p] = salt[i];

      /*-----------------------------*/
      /* Instantiate hash algorithm. */
      /*-----------------------------*/
      HashAlgorithm hash;

      if      (algo == SHA1)   hash = new SHA1Managed();
      else if (algo == SHA256) hash = new SHA256Managed();
      else if (algo == SHA384) hash = new SHA384Managed();
      else if (algo == SHA512) hash = new SHA512Managed();
      else                     hash = new MD5CryptoServiceProvider();

      /*----------------------------------------*/
      /* Create encrypted hash and append salt. */
      /*----------------------------------------*/
      byte[] hashBytes   = hash.ComputeHash(textAndSalt);
      byte[] hashAndSalt = new byte[hashBytes.Length + salt.Length];

      for (int i=0; i < hashBytes.Length; i++)
        hashAndSalt[i] = hashBytes[i];

      for (int i=0, p=hashBytes.Length; i < salt.Length; i++, p++)
        hashAndSalt[p] = salt[i];

      /*--------------------------------------*/
      /* Convert result to base64 and return. */
      /*--------------------------------------*/
      return Convert.ToBase64String(hashAndSalt);
      }

    /***************************************************************************
    * verify */
    /**
    * Compares a text value to a hash encrypted by {@link encrypt}.
    * <code>text</code> is encrypted with the salt at the end of
    * <code>hash</code> and true is returned if the result matches
    * <code>hash</code>.
    *
    * @param  text  Text to be Compared
    * @param  algo  Hashing Algorithm
    * @param  hash  Base64 Encoded Encrypted Hash
    * @return       true=Text Matches Encrypted Hash
    ***************************************************************************/
    public static bool verify(string text, string algo, string hash)
      {
      /*-----------------------------------------------*/
      /* Find the size of the hash from the algorithm. */
      /*-----------------------------------------------*/
      int hashSize;

      if      (algo == SHA1)   hashSize = 160/8;
      else if (algo == SHA256) hashSize = 256/8;
      else if (algo == SHA384) hashSize = 384/8;
      else if (algo == SHA512) hashSize = 512/8;
      else                     hashSize = 128/8;

      /*-----------------------------------------------------*/
      /* Get the encrypted byte array from the encoded hash. */
      /*-----------------------------------------------------*/
      byte[] hashAndSalt = Convert.FromBase64String(hash);
      byte[] salt        = new byte[hashAndSalt.Length - hashSize];

      for (int i=0, p=hashSize; i < salt.Length; i++, p++)
        salt[i] = hashAndSalt[p];

      /*-------------------------------------------*/
      /* Encrypt the text with the salt and return */
      /* true if result matches encrypted hash.    */
      /*-------------------------------------------*/
      return (encrypt(text, algo, salt) == hash);
      }

    /*****************************************************************************
    * Test Main
    *****************************************************************************/
    [STAThread]
    static void Main(string[] args)
      {
      string rightPass  = "myP@5sw0rd";
      string wrongPass  = "password";
      string hashMD5    = encrypt(rightPass, MD5,    null);
      string hashSha1   = encrypt(rightPass, SHA1,   null);
      string hashSha256 = encrypt(rightPass, SHA256, null);
      string hashSha384 = encrypt(rightPass, SHA384, null);
      string hashSha512 = encrypt(rightPass, SHA512, null);

      Console.WriteLine("COMPUTING HASH VALUES\r\n");
      Console.WriteLine("MD5   : {0}", hashMD5);
      Console.WriteLine("SHA1  : {0}", hashSha1);
      Console.WriteLine("SHA256: {0}", hashSha256);
      Console.WriteLine("SHA384: {0}", hashSha384);
      Console.WriteLine("SHA512: {0}", hashSha512);
      Console.WriteLine("");

      Console.WriteLine("COMPARING PASSWORD HASHES\r\n");
      Console.WriteLine("MD5    (good): {0}", verify(rightPass, MD5,    hashMD5));
      Console.WriteLine("MD5    (bad) : {0}", verify(wrongPass, MD5,    hashMD5));
      Console.WriteLine("SHA1   (good): {0}", verify(rightPass, SHA1,   hashSha1));
      Console.WriteLine("SHA1   (bad) : {0}", verify(wrongPass, SHA1,   hashSha1));
      Console.WriteLine("SHA256 (good): {0}", verify(rightPass, SHA256, hashSha256));
      Console.WriteLine("SHA256 (bad) : {0}", verify(wrongPass, SHA256, hashSha256));
      Console.WriteLine("SHA384 (good): {0}", verify(rightPass, SHA384, hashSha384));
      Console.WriteLine("SHA384 (bad) : {0}", verify(wrongPass, SHA384, hashSha384));
      Console.WriteLine("SHA512 (good): {0}", verify(rightPass, SHA512, hashSha512));
      Console.WriteLine("SHA512 (bad) : {0}", verify(wrongPass, SHA512, hashSha512));
      }
    }
  }










