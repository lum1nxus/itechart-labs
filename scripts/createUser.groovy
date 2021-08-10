#!groovy
import hudson.security.*
import jenkins.model.*
import hudson.security.csrf.DefaultCrumbIssuer
def instance = Jenkins.getInstance()
def hudsonRealm = new HudsonPrivateSecurityRealm(false)
def users = hudsonRealm.getAllUsers()
instance.setCrumbIssuer(new DefaultCrumbIssuer(true))
instance.save()
users_s = users.collect { it.toString() }

// Create the admin user account if it doesn't already exist.
if ("luminxus" in users_s) {
    println "Admin user already exists - updating password"

    def user = hudson.model.User.get('luminxus');
    def password = hudson.security.HudsonPrivateSecurityRealm.Details.fromPlainPassword('08052212')
    user.addProperty(password)
    user.save()
}
else {
    println "--> creating local admin user"

    hudsonRealm.createAccount('luminxus', '08052212')
    instance.setSecurityRealm(hudsonRealm)

    def strategy = new FullControlOnceLoggedInAuthorizationStrategy()
    instance.setAuthorizationStrategy(strategy)
    instance.save()
}