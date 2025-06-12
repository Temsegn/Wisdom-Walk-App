const cron = require("node-cron")
const { cleanupTempFiles, getStorageStats } = require("./localStorageService")

// Clean up temporary files every day at 2 AM
const scheduleFileCleanup = () => {
  cron.schedule("0 2 * * *", async () => {
    try {
      console.log("Starting scheduled file cleanup...")
      const deletedCount = await cleanupTempFiles(24) // Delete files older than 24 hours
      console.log(`File cleanup completed. Deleted ${deletedCount} temporary files.`)

      // Log storage statistics
      const stats = await getStorageStats()
      console.log("Storage Statistics:", {
        totalFiles: stats.totalFiles,
        totalSizeMB: (stats.totalSize / (1024 * 1024)).toFixed(2),
        byFolder: Object.entries(stats.byFolder).map(([folder, data]) => ({
          folder,
          files: data.files,
          sizeMB: (data.size / (1024 * 1024)).toFixed(2),
        })),
      })
    } catch (error) {
      console.error("Error during scheduled file cleanup:", error)
    }
  })

  console.log("File cleanup scheduler initialized - runs daily at 2 AM")
}

module.exports = {
  scheduleFileCleanup,
}
