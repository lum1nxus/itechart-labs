import jenkins.model.*
import org.jfrog.*
import org.jfrog.hudson.*
import org.jfrog.hudson.util.Credentials;

def inst = Jenkins.getInstance()

def desc = inst.getDescriptor("org.jfrog.hudson.ArtifactoryBuilder")

def deployerCredentials = new CredentialsConfig("luminxus", "08052212", "")
def resolverCredentials = new CredentialsConfig("", "", "")

def sinst = [new ArtifactoryServer(
  "artifactory",
  "http://172.16.1.50:8081/artifactory",
  deployerCredentials,
  resolverCredentials,
  300,
  false,
  3 )
]

desc.setArtifactoryServers(sinst)

desc.save()