#!groovy
import com.cloudbees.plugins.credentials.impl.*
import com.cloudbees.plugins.credentials.*
import com.cloudbees.plugins.credentials.domains.*
import com.cloudbees.jenkins.plugins.sshcredentials.impl.*

def source = new BasicSSHUserPrivateKey.DirectEntryPrivateKeySource("25423")
def ck1 = new BasicSSHUserPrivateKey(CredentialsScope.GLOBAL, "github-ssh-key", "luminxus", source, "passphrase", "github-ssh-key")

SystemCredentialsProvider.getInstance().getStore().addCredentials(Domain.global(), ck1)