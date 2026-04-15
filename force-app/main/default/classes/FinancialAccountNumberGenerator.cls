public with sharing class FinancialAccountNumberGenerator {

    public static String generateCardNumber() {
        Long nowValue = DateTime.now().getTime();
        String rawValue = String.valueOf(nowValue);

        while (rawValue.length() < 16) {
            rawValue += '0';
        }

        if (rawValue.length() > 16) {
            rawValue = rawValue.substring(rawValue.length() - 16);
        }

        return rawValue;
    }
}