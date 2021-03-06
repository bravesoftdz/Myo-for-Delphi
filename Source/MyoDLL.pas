// Ported to Delphi from C++ by @davidberneda
// david@steema.com
unit MyoDLL;

{$MINENUMSIZE 4}

interface

const Myo_DLL =
{$IFDEF MACOS}
  {$IFDEF IOS}

  // The MyoKit library file should be copied to ie:
  // $(BDSPLATFORMSDKSDIR)\iPhoneOS7.1.sdk

  '/MyoKit'

  {$ELSE}
  'myo.86'
  {$ENDIF}
{$ELSE}
{$IFDEF CPUX86}
  'myo32.dll'
{$ELSE}
{$IFDEF CPUX64}
  'myo64.dll'
{$ELSE}
  'myo32.dll' // Delphi 7
{$ENDIF}
{$ENDIF}
{$ENDIF}
  ;

type
  float=Single;
  int8_t=Byte;
  libmyo_hub_t = Pointer;

/// \defgroup errors Error Handling
/// @{

/// Function result codes.
/// All libmyo functions that can fail return a value of this type.
type
  libmyo_result_t = (
    libmyo_success,
    libmyo_error,
    libmyo_error_invalid_argument,
    libmyo_error_runtime
    );

/// Opaque handle to detailed error information.
type
  libmyo_error_details_t = Pointer;

/// Return a null-terminated string with a detailed error message.

function libmyo_error_cstring(details:libmyo_error_details_t):{$IFDEF MACOS}MarshaledAString{$ELSE}PAnsiChar{$ENDIF}; cdecl;
         external Myo_DLL {$IFDEF MACOS}name '_libmyo_error_cstring'{$ENDIF};

/// Returns the kind of error that occurred.
function libmyo_error_kind(details:libmyo_error_details_t):libmyo_result_t; cdecl;
         external Myo_DLL {$IFDEF MACOS}name '_libmyo_error_kind'{$ENDIF};

/// Free the resources allocated by an error object.
procedure libmyo_free_error_details(details:libmyo_error_details_t); cdecl;
          external Myo_DLL {$IFDEF MACOS}name '_libmyo_free_error_details'{$ENDIF};

/// @}

/// @defgroup libmyo_hub Hub instance
/// @{

/// Initialize a connection to the hub.
/// \a application_identifier must follow a reverse domain name format (ex. com.domainname.appname). Application
/// identifiers can be formed from the set of alphanumeric ASCII characters (a-z, A-Z, 0-9). The hyphen (-) and
/// underscore (_) characters are permitted if they are not adjacent to a period (.) character (i.e. not at the start or
/// end of each segment), but are not permitted in the top-level domain. Application identifiers must have three or more
/// segments. For example, if a company's domain is example.com and the application is named hello-world, one could use
/// "com.example.hello-world" as a valid application identifier. \a application_identifier can be NULL or empty.
/// @returns libmyo_success if the connection is successfully established, otherwise:
///  - libmyo_error_runtime if a connection could not be established
///  - libmyo_error_invalid_argument if \a out_hub is NULL
///  - libmyo_error_invalid_argument if \a application_identifier is longer than 255 characters
///  - libmyo_error_invalid_argument if \a application_identifier is not in the proper reverse domain name format
function libmyo_init_hub(out out_hub:libmyo_hub_t;
                         const application_identifier:{$IFDEF MACOS}MarshaledAString{$ELSE}PAnsiChar{$ENDIF};
                         var out_error:libmyo_error_details_t):libmyo_result_t; cdecl;
                         external Myo_DLL {$IFDEF MACOS}name '_libmyo_init_hub'{$ENDIF};

/// Free the resources allocated to a hub.
/// @returns libmyo_success if shutdown is successful, otherwise:
///  - libmyo_error_invalid_argument if \a hub is NULL
///  - libmyo_error if \a hub is not a valid hub
function libmyo_shutdown_hub(hub:libmyo_hub_t; var out_error:libmyo_error_details_t):libmyo_result_t; cdecl;
         external Myo_DLL {$IFDEF MACOS}name '_libmyo_shutdown_hub'{$ENDIF};

// Locking policies.
type
  libmyo_locking_policy_t = (
    libmyo_locking_policy_none,    ///< Pose events are always sent.
    libmyo_locking_policy_standard ///< Pose events are not sent while a Myo is locked.
    );

/// Set the locking policy for Myos connected to the hub.
/// @returns libmyo_success if the locking policy is successfully set, otherwise
///  - libmyo_error_invalid_argument if \a hub is NULL
///  - libmyo_error if \a hub is not a valid hub
function libmyo_set_locking_policy(hub:libmyo_hub_t; locking_policy:libmyo_locking_policy_t;
                                          var out_error:libmyo_error_details_t):libmyo_result_t; cdecl;
                                          external Myo_DLL {$IFDEF MACOS}name '_libmyo_set_locking_policy'{$ENDIF}

/// @}

/// @defgroup libmyo_myo Myo instances
/// @{

/// Opaque type corresponding to a known Myo device.
type
  libmyo_myo_t = Pointer;

/// Types of vibration
type
  libmyo_vibration_type_t = (
    libmyo_vibration_short,
    libmyo_vibration_medium,
    libmyo_vibration_long
  );

/// Vibrate the given myo.
/// Can be called when a Myo is paired.
/// @returns libmyo_success if the Myo successfully vibrated, otherwise
///  - libmyo_error_invalid_argument if \a myo is NULL
function libmyo_vibrate(myo:libmyo_myo_t; vibration:libmyo_vibration_type_t; var out_error:libmyo_error_details_t):libmyo_result_t; cdecl;
         external Myo_DLL {$IFDEF MACOS}name '_libmyo_vibrate'{$ENDIF};

/// Request the RSSI for a given myo.
/// Can be called when a Myo is paired. A libmyo_event_rssi event will likely be generated with the value of the RSSI.
/// @returns libmyo_success if the Myo successfully got the RSSI, otherwise
///  - libmyo_error_invalid_argument if \a myo is NULL
function libmyo_request_rssi(myo:libmyo_myo_t; var out_error:libmyo_error_details_t):libmyo_result_t; cdecl;
         external Myo_DLL {$IFDEF MACOS}name '_libmyo_request_rssi'{$ENDIF};

/// @}

/// @defgroup libmyo_poses Pose recognition.
/// @{

/// Supported poses.
type
  libmyo_pose_t = (
    libmyo_pose_rest           = 0, ///< Rest pose.
    libmyo_pose_fist           = 1, ///< User is making a fist.
    libmyo_pose_wave_in        = 2, ///< User has an open palm rotated towards the posterior of their wrist.
    libmyo_pose_wave_out       = 3, ///< User has an open palm rotated towards the anterior of their wrist.
    libmyo_pose_fingers_spread = 4, ///< User has an open palm with their fingers spread away from each other.
    libmyo_pose_double_tap     = 5, ///< User is touching the tip of their thumb to the tip of their pinky.

    libmyo_num_poses,               ///< Number of poses supported; not a valid pose.

    libmyo_pose_unknown = $ffff    ///< Unknown pose.
  );

/// @}

/// @defgroup libmyo_locking Myo locking mechanism

/// Valid unlock types.
type
  libmyo_unlock_type_t = (
    libmyo_unlock_timed = 0, ///< Unlock for a fixed period of time.
    libmyo_unlock_hold  = 1 ///< Unlock until explicitly told to re-lock.
    );

/// Unlock the given Myo.
/// Can be called when a Myo is paired. A libmyo_event_unlocked event will be generated if the Myo was locked.
/// @returns libmyo_success if the Myo was successfully unlocked, otherwise
///  - libmyo_error_invalid_argument if \a myo is NULL
function libmyo_myo_unlock(myo:libmyo_myo_t; _type:libmyo_unlock_type_t; var out_error:libmyo_error_details_t):libmyo_result_t; cdecl;
         external Myo_DLL {$IFDEF MACOS}name '_libmyo_myo_unlock'{$ENDIF};

/// Lock the given Myo immediately.
/// Can be called when a Myo is paired. A libmyo_event_locked event will be generated if the Myo was unlocked.
/// @returns libmyo_success if the Myo was successfully locked, otherwise
///  - libmyo_error_invalid_argument if \a myo is NULL
function libmyo_myo_lock(myo:libmyo_myo_t; var out_error:libmyo_error_details_t):libmyo_result_t; cdecl;
         external Myo_DLL {$IFDEF MACOS}name '_libmyo_myo_lock'{$ENDIF};

/// User action types.
type
  libmyo_user_action_type_t = (
    libmyo_user_action_single = 0 ///< User did a single, discrete action, such as pausing a video.
    );

/// Notify the given Myo that a user action was recognized.
/// Can be called when a Myo is paired. Will cause Myo to vibrate.
/// @returns libmyo_success if the Myo was successfully notified, otherwise
///  - libmyo_error_invalid_argument if \a myo is NULL
function libmyo_myo_notify_user_action(myo:libmyo_myo_t; _type:libmyo_user_action_type_t;
                                              var out_error:libmyo_error_details_t):libmyo_result_t; cdecl;
         external Myo_DLL {$IFDEF MACOS}name '_libmyo_myo_notify_user_action'{$ENDIF};

/// @}
/// @defgroup libmyo_events Event Handling
/// @{

/// Types of events.
type
  libmyo_event_type_t = (
    libmyo_event_paired, ///< Successfully paired with a Myo.
    libmyo_event_unpaired, ///< Successfully unpaired from a Myo.
    libmyo_event_connected, ///< A Myo has successfully connected.
    libmyo_event_disconnected, ///< A Myo has been disconnected.
    libmyo_event_arm_synced, ///< A Myo has recognized that the sync gesture has been successfully performed.
    libmyo_event_arm_unsynced, ///< A Myo has been moved or removed from the arm.
    libmyo_event_orientation, ///< Orientation data has been received.
    libmyo_event_pose, ///< A change in pose has been detected. @see libmyo_pose_t.
    libmyo_event_rssi, ///< An RSSI value has been received.
    libmyo_event_unlocked,         ///< A Myo has become unlocked.
    libmyo_event_locked           ///< A Myo has become locked.
  );

/// Information about an event.
type
  libmyo_event_t = Pointer;

/// Retrieve the type of an event.
function libmyo_event_get_type(event:libmyo_event_t):libmyo_event_type_t; cdecl;
         external Myo_DLL {$IFDEF MACOS}name '_libmyo_event_get_type'{$ENDIF};

/// Retrieve the timestamp of an event.
/// @see libmyo_now() for details on timestamps.
function libmyo_event_get_timestamp(event:libmyo_event_t):UInt64; cdecl;
         external Myo_DLL {$IFDEF MACOS}name '_libmyo_event_get_timestamp'{$ENDIF};

/// Retrieve the Myo associated with an event.
function libmyo_event_get_myo(event:libmyo_event_t):libmyo_myo_t; cdecl;
         external Myo_DLL {$IFDEF MACOS}name '_libmyo_event_get_myo'{$ENDIF};

/// Components of version.
type
  libmyo_version_component_t = (
    libmyo_version_major,        ///< Major version.
    libmyo_version_minor,        ///< Minor version.
    libmyo_version_patch,        ///< Patch version.
    libmyo_version_hardware_rev ///< Hardware revision.
  );

/// Hardware revisions.
type
  libmyo_hardware_rev_t = (
    libmyo_hardware_rev_c = 1, ///< Alpha units
    libmyo_hardware_rev_d = 2 ///< Consumer units
  );

{$IFNDEF D9}
type
  UInt32=Cardinal;
{$ENDIF}

/// Retrieve the Myo armband's firmware version from this event.
/// Valid for libmyo_event_paired and libmyo_event_connected events.
function libmyo_event_get_firmware_version(event:libmyo_event_t; version:libmyo_version_component_t):UInt32; cdecl;
         external Myo_DLL {$IFDEF MACOS}name '_libmyo_event_get_firmware_version'{$ENDIF};

/// Enumeration identifying a right arm or left arm. @see libmyo_event_get_arm().
type
  libmyo_arm_t = (
    libmyo_arm_right, ///< Myo is on the right arm.
    libmyo_arm_left, ///< Myo is on the left arm.
    libmyo_arm_unknown ///< Unknown arm.
  );

/// Retrieve the arm associated with an event.
/// Valid for libmyo_event_arm_synced events only.
function libmyo_event_get_arm(event:libmyo_event_t):libmyo_arm_t; cdecl;
         external Myo_DLL {$IFDEF MACOS}name '_libmyo_event_get_arm'{$ENDIF};

/// Possible directions for Myo's +x axis relative to a user's arm.
type
 libmyo_x_direction_t = (
    libmyo_x_direction_toward_wrist, ///< Myo's +x axis is pointing toward the user's wrist.
    libmyo_x_direction_toward_elbow, ///< Myo's +x axis is pointing toward the user's elbow.
    libmyo_x_direction_unknown ///< Unknown +x axis direction.
  );

/// Retrieve the x-direction associated with an event.
/// The x-direction specifies which way Myo's +x axis is pointing relative to the user's arm.
/// Valid for libmyo_event_arm_synced events only.
function libmyo_event_get_x_direction(event:libmyo_event_t):libmyo_x_direction_t; cdecl;
         external Myo_DLL {$IFDEF MACOS}name '_libmyo_event_get_x_direction'{$ENDIF};

/// Index into orientation data, which is provided as a quaternion.
/// Orientation data is returned as a unit quaternion of floats, represented as `w + x * i + y * j + z * k`.
type
  libmyo_orientation_index = (
    libmyo_orientation_x = 0, ///< First component of the quaternion's vector part
    libmyo_orientation_y = 1, ///< Second component of the quaternion's vector part
    libmyo_orientation_z = 2, ///< Third component of the quaternion's vector part
    libmyo_orientation_w = 3  ///< Scalar component of the quaternion.
  );

/// Retrieve orientation data associated with an event.
/// Valid for libmyo_event_orientation events only.
/// @see libmyo_orientation_index
function libmyo_event_get_orientation(event:libmyo_event_t; index:libmyo_orientation_index):float; cdecl;
         external Myo_DLL {$IFDEF MACOS}name '_libmyo_event_get_orientation'{$ENDIF};

/// Retrieve raw accelerometer data associated with an event in units of g.
/// Valid for libmyo_event_orientation events only.
/// Requires `index < 3`.
function libmyo_event_get_accelerometer(event:libmyo_event_t; index:UInt32):float; cdecl;
         external Myo_DLL {$IFDEF MACOS}name '_libmyo_event_get_accelerometer'{$ENDIF};

/// Retrieve raw gyroscope data associated with an event in units of deg/s.
/// Valid for libmyo_event_orientation events only.
/// Requires `index < 3`.
function libmyo_event_get_gyroscope(event:libmyo_event_t; index:UInt32):float; cdecl;
         external Myo_DLL {$IFDEF MACOS}name '_libmyo_event_get_gyroscope'{$ENDIF};

/// Retrieve the pose associated with an event.
/// Valid for libmyo_event_pose events only.
function libmyo_event_get_pose(event:libmyo_event_t):libmyo_pose_t; cdecl;
         external Myo_DLL {$IFDEF MACOS}name '_libmyo_event_get_pose'{$ENDIF};

/// Retreive the RSSI associated with an event.
/// Valid for libmyo_event_rssi events only.
function libmyo_event_get_rssi(event:libmyo_event_t):int8_t; cdecl;
         external Myo_DLL {$IFDEF MACOS}name '_libmyo_event_get_rssi'{$ENDIF};

/// Return type for event handlers.
type
  libmyo_handler_result_t = (
    libmyo_handler_continue, ///< Continue processing events
    libmyo_handler_stop     ///< Stop processing events
  );

/// Callback function type to handle events as they occur from libmyo_run().
type
  libmyo_handler_t = function(user_data:Pointer; event:libmyo_event_t):libmyo_handler_result_t; cdecl;
  plibmyo_handler_t = ^libmyo_handler_t;

/// Process events and call the provided callback as they occur.
/// Runs for up to approximately \a duration_ms milliseconds or until a called handler returns libmyo_handler_stop.
/// @returns libmyo_success after a successful run, otherwise
///  - libmyo_error_invalid_argument if \a hub is NULL
///  - libmyo_error_invalid_argument if \a handler is NULL
function libmyo_run(hub:libmyo_hub_t; duration_ms:UInt32; handler:plibmyo_handler_t;
                           user_data:Pointer;
                           var out_error:libmyo_error_details_t):libmyo_result_t; cdecl;
                           external Myo_DLL {$IFDEF MACOS}name '_libmyo_run'{$ENDIF};


implementation

end.
