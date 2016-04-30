job('staci') {

  scm {
    github('Praqma/staci', 'origin/ready/**')
  }
  // Add recommended git extensions
  configure { project ->
    project / scm / extensions << 'hudson.plugins.git.extensions.impl.CleanCheckout'()
    project / scm / extensions << 'hudson.plugins.git.extensions.impl.PruneStaleBranch'()
  }

  wrappers {
    pretestedIntegration('SQUASHED', 'master', 'origin')
  }

  steps {
    shell('''\n
    # Does the staci script exist?
    ls staci.sh

    # Does it have a help option printing usage?
    ./staci.sh -h | grep Usage
    '''.stripIndent())
  }

  publishers {
  	pretestedIntegration()
  }

}
