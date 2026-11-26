class DoctorAdminError extends Error {
  constructor(code, message) {
    super(message);
    this.name = 'DoctorAdminError';
    this.code = code;
  }
}

module.exports = { DoctorAdminError };
