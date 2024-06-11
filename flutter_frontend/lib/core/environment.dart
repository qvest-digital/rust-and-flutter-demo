enum Environment { local, prod }

const _env = String.fromEnvironment('ENVIRONMENT', defaultValue: 'local');

Environment getEnv() => _env == 'prod' ? Environment.prod : Environment.local;
