#include "msgpuck.h"
#include "module.h"
#include "mp_decimal.h"
#include "lua/tnt_msgpuck.h"
#include "mp_uuid.h"

enum {
	BUF_SIZE = 512,
};

int
S3(box_function_ctx_t *ctx, const char *args, const char *args_end)
{
	(void)args_end;
	uint32_t arg_count = mp_decode_array(&args);
	if (arg_count != 2) {
		return box_error_set(__FILE__, __LINE__, ER_PROC_C,
				     "invalid argument count");
	}
	int sum = 0;
	if (mp_typeof(*args) != MP_UINT)
		mp_decode_nil(&args);
	else
		sum = mp_decode_uint(&args);
	sum += mp_decode_uint(&args);
	char res[BUF_SIZE];
	char *end = mp_encode_uint(res, sum);
	box_return_mp(ctx, res, end);
	return 0;
}

int
S3_finalize(box_function_ctx_t *ctx, const char *args, const char *args_end)
{
	(void)args_end;
	uint32_t arg_count = mp_decode_array(&args);
	if (arg_count != 1) {
		return box_error_set(__FILE__, __LINE__, ER_PROC_C,
				     "invalid argument count");
	}
	int sum = 0;
	if (mp_typeof(*args) == MP_UINT)
		sum = mp_decode_uint(&args);
	char res[BUF_SIZE];
	char *end = mp_encode_double(res, sum / 10.0);
	box_return_mp(ctx, res, end);
	return 0;
}
