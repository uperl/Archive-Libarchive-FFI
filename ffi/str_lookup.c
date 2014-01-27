#include <stdlib.h>
#include <string.h>
#include <archive.h>
#include <archive_entry.h>

struct user_data_t;

typedef void (*lookup_cb_t)(struct user_data_t *, __LA_INT64_T);
typedef void (*cleanup_cb_t)(void);

struct user_data_t {
  lookup_cb_t lookup;
  cleanup_cb_t cleanup;
  char *buffer;
  int  is_null;
};

static const char *
my_lookup(void *data, __LA_INT64_T id)
{
  struct user_data_t *ud = (struct user_data_t *)data;

  ud->is_null = 1;
  (ud->lookup)(ud, id);
  if(ud->is_null)
    return NULL;
  else
    return ud->buffer;
}

static void
my_cleanup(void *data)
{
  struct user_data_t *ud = (struct user_data_t *)data;
  (ud->cleanup)();
  free(ud->buffer);
  free(ud);
}

void
my_set_user_data_name(struct user_data_t *ud, const char *name)
{
  int len;
  if(name == NULL)
  {
    ud->is_null = 1;
  }
  else
  {
    len = strlen(name);
    ud->is_null = 0;
    ud->buffer = realloc(ud->buffer, len+1);
    strncpy(ud->buffer, name, len+1);
  }
}

typedef int (setf_t)(
  struct archive *archive, 
  void *,
  void *,
  void *
);

static int
my_set_lookup(setf_t *setf, struct archive *archive, lookup_cb_t lookup, cleanup_cb_t cleanup)
{
  struct user_data_t *ud;
  int ret;

  if(lookup != NULL || cleanup != NULL)
  {
    ud          = (struct user_data_t *) malloc(sizeof(struct user_data_t));
    ud->lookup  = lookup;
    ud->cleanup = cleanup;
    ud->buffer  = (char *) malloc(33);
    ret = setf(archive, (void *)ud, (void*)my_lookup, (void*)my_cleanup);
  }
  else
    ret = setf(archive, NULL, NULL, NULL);

  return ret;
}

int
my_archive_read_disk_set_gname_lookup(struct archive *archive, lookup_cb_t lookup, cleanup_cb_t cleanup)
{
  return my_set_lookup((setf_t*)archive_read_disk_set_gname_lookup, archive, lookup, cleanup);
}

int
my_archive_read_disk_set_uname_lookup(struct archive *archive, lookup_cb_t lookup, cleanup_cb_t cleanup)
{
  return my_set_lookup((setf_t*)archive_read_disk_set_uname_lookup, archive, lookup, cleanup);
}
