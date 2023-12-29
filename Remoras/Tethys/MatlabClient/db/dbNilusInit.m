%Script to initialize Nilus

message = {
    'dbNilusInit is no longer required.'
    'When dbInit is called, it automatically sets up the appropriate'
    'Nilus libraries.  This file will be removed in future releases.'
    'Be certain to call dbInit before attempting to use the'
    'Nilus XML generator libraries.'
    };

warning(strjoin(message, '\n'));

