class Auth {
    constructor() {
        this.authenticated = false;
    }

    login(cb) {
        this.authenticated = true;
        if(cb)
            cb();
    }

    logout(cb) {
        this.authenticated = false;
        if(cb)
            cb();
    }

    isAuthenticated() {
        return this.authenticated;
    }
}
export default new Auth();