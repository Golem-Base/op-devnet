{
  pkgs,
  host ? "localhost",
  port ? "8082",
  consensus-url,
  execution-url,
}:
pkgs.writeTextFile {
  name = "dora-config.yml";
  text = ''
    logging:
      #outputLevel: "info"
      #outputStderr: false

      #filePath: "explorer.log"
      #fileLevel: "warn"

    # Chain network configuration
    chain:
      displayName: "Local Devnet"

    # HTTP Server configuration
    server:
      host: ${host} # Address to listen on
      port: ${port} # Port to listen on

    frontend:
      enabled: true # Enable or disable to web frontend
      debug: false
      minimize: false # minimize html templates

      # Name of the site, displayed in the title tag
      siteName: "Dora the Explorer"
      siteSubtitle: ""

      # link to EL Explorer
      ethExplorerLink: ""

      # file or inventory url to load validator names from
      validatorNamesYaml: ""
      validatorNamesInventory: ""

      # frontend features
      showSensitivePeerInfos: false
      showPeerDASInfos: false
      showSubmitDeposit: false
      showSubmitElRequests: false

    beaconapi:
      # beacon node rpc endpoints
      endpoints:
        - name: "local"
          url: ${consensus-url}

      # local cache for page models
      localCacheSize: 100 # 100MB

      # remote cache for page models
      redisCacheAddr: ""
      redisCachePrefix: ""

    executionapi:
      # execution node rpc endpoints
      endpoints:
        - name: "local"
          url: ${execution-url}

      logBatchSize: 1000

      # el block number from where to crawl the deposit contract (should be <=, but close to the deposit contract deployment block)
      depositDeployBlock: 0

      # el block number from where to crawl the electra system contracts (should be <=, but close to electra fork activation block)
      electraDeployBlock: 0 

    # indexer keeps track of the latest epochs in memory.
    indexer:
      # max number of epochs to keep in memory
      inMemoryEpochs: 3

      # number of epochs to keep validator activity history for (high memory usage for large validator sets)
      activityHistoryLength: 6

      # disable synchronizing historic data
      disableSynchronizer: false

      # reset synchronization state to this epoch on startup - only use to resync database, comment out afterwards
      #resyncFromEpoch: 0

      # force re-synchronization of epochs that are already present in DB - only use to fix missing data after schema upgrades
      #resyncForceUpdate: true

      # number of seconds to pause the synchronization between each epoch (don't overload CL client)
      syncEpochCooldown: 2

      # maximum number of parallel beacon state requests (might cause high memory usage)
      maxParallelValidatorSetRequests: 1

    # database configuration
    database:
      engine: "sqlite" # sqlite / pgsql

      # sqlite settings (only used if engine is sqlite)
      sqlite:
        file: "./explorer-db.sqlite"
  '';
}
